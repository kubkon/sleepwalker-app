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

enum DataManagerError: Error {
    case CouldntStartWorkoutSession
    case CouldntParseAccelerometerData
}

class DataManager : NSObject {
    static let Fs = 10 // 10Hz
    
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
        dm.motionManager.accelerometerUpdateInterval = 1 / Double(DataManager.Fs)
        return dm
    }
    
    fileprivate override init() {
        self.motionManager = CMMotionManager()
        self.healthStore = HKHealthStore()
        super.init()
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
            self.buffer.append(reading)
            if self.buffer.count == DataManager.Fs {
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
