//
//  InterfaceController.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 21/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreMotion
import HealthKit

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var startRecordingButton: WKInterfaceButton!
    
    static let fs = 10 // 10 Hz
    var sessionActivated = false
    var accelActivated = false
    var session : WCSession?
    var buffer : [Byte] = []
    let motionManager = CMMotionManager()
    let healthStore = HKHealthStore()
    var workoutSession : HKWorkoutSession?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        if (WCSession.isSupported() && !sessionActivated) {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            print("Activating the session!")
        }
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func startRecordingButtonTapped() {
        print("startRecordingButton pressed!")
        if !sessionActivated {
            return
        }
        if !accelActivated {
            workoutSession = try! HKWorkoutSession(configuration: HKWorkoutConfiguration.init())
            healthStore.start(workoutSession!)
            startRecordingButton.setTitle("Stop")
            if motionManager.isAccelerometerAvailable {
                motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                    guard let data = data else {
                        print("Couldn't unwrap accelerometer data: \(String(describing: error))")
                        return
                    }
                    let reading = AccelReading(fromX: data.acceleration.x, fromY: data.acceleration.y, fromZ: data.acceleration.z)
                    self.buffer += reading.toBytes()
                    if (self.buffer.count == 3 * 8 * InterfaceController.fs * 10) { // 10secs, send the data
                        let message = Data(bytes: self.buffer)
                        WCSession.default.transferUserInfo(["timestamp" : Date.init().timeIntervalSince1970, "data" : message])
                        self.buffer.removeAll()
                    }
                })
            }
        }
        else {
            startRecordingButton.setTitle("Start")
            motionManager.stopAccelerometerUpdates()
            buffer.removeAll()
            if let workoutSession = workoutSession {
                healthStore.end(workoutSession)
            }
        }
        accelActivated = !accelActivated
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activated!")
        sessionActivated = true
    }
}
