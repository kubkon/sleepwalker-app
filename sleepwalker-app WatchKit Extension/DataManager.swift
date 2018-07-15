//
//  DataManager.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 10/06/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation
import CoreMotion
import HealthKit
import os

enum DataManagerError: Error {
    case CouldntStartWorkoutSession
    case CouldntParseAccelerometerData
}

class DataManager : NSObject {
    fileprivate var motionManager: CMMotionManager
    fileprivate var healthStore: HKHealthStore
    fileprivate var workoutSession: HKWorkoutSession?
    
    fileprivate var _isRunning = false
    var isRunning: Bool {
        get { return _isRunning }
    }
    
    fileprivate var buffer: [AccelReading] = []
    
    static func new() -> DataManager? {
        let dm = DataManager()
        if !dm.motionManager.isAccelerometerAvailable { return nil }
        dm.motionManager.accelerometerUpdateInterval = 1 / Double(Constants.SamplingRate)
        return dm
    }
    
    fileprivate override init() {
        self.motionManager = CMMotionManager()
        self.healthStore = HKHealthStore()
        
        let requestedTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!])
        healthStore.requestAuthorization(toShare: nil, read: requestedTypes, completion: {(success, error) in
            if !success {
                os_log("Reading HeartRate was not authorized by the user", log: OSLog.default, type: .error)
                // handle error here
            }
        })
        
        super.init()
    }
    
    fileprivate func fetchLatestHeartRateSample(completion: @escaping (_ samples: [HKQuantitySample]?) -> Void) {
        // create sample type for the heart rate
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(nil)
            return
        }
        
        // predicate for specifying start and end dates for the query
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        //set sorting by date
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        // create the query
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if error != nil {
                                        os_log("Error fetching latest heart rate samples",
                                               log: OSLog.default,
                                               type: .error, "\(error.debugDescription)")
                                        completion(nil)
                                        return
                                    }
                                    completion(results as? [HKQuantitySample])
        }
        
        // execute the query
        healthStore.execute(query)
    }
    
    func start(withUpdatesHandler handler: (([AccelReading]?, Error?) -> Void)!) {
        if _isRunning { return }
        if workoutSession == nil {
            guard let session = try? HKWorkoutSession(configuration: HKWorkoutConfiguration.init()) else {
                handler(nil, DataManagerError.CouldntStartWorkoutSession)
                return
            }
            workoutSession = session
        }
        healthStore.start(self.workoutSession!)
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
            if let error = error { handler(nil, error); return }
            guard let data = data else { handler(nil, DataManagerError.CouldntParseAccelerometerData); return }
            let reading = AccelReading(
                fromTimestamp: Date.init().timeIntervalSince1970,
                fromX: data.acceleration.x,
                fromY: data.acceleration.y,
                fromZ: data.acceleration.z
            )
            
            // fetch latest heart rate data (sync wrt accelerometer polling frequency)
            self.fetchLatestHeartRateSample(completion: {(results) in
                if let results = results {
                    os_log("Received new heart rate samples: %@", log: OSLog.default, type: .info, "\(results)")
                }
            })
            
            self.buffer.append(reading)
            if self.buffer.count == Constants.SamplingRate * Constants.SamplingWindow {
                handler(self.buffer, nil)
                self.buffer.removeAll()
            }
        })
        _isRunning = true
    }
    
    func stop() {
        if !_isRunning { return }
        motionManager.stopAccelerometerUpdates()
        if let session = workoutSession {
            healthStore.end(session)
        }
        _isRunning = false
    }
}
