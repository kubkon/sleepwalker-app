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

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var startRecordingButton: WKInterfaceButton!
    
    var sessionActivated = false
    var buffer : [AccelReading] = []
    let motionManager = CMMotionManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
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
        if (WCSession.isSupported() && !sessionActivated) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("Activating a session...")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activated!")
        sessionActivated = true
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                if let data = data {
                    let reading = AccelReading(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                    self.buffer.append(reading)
                    if (self.buffer.count == 600) { // 60secs, send the data
                        let rawBytes = pack(self.buffer)
                        let message = Data(bytes: rawBytes)
                        WCSession.default.sendMessageData(message, replyHandler: nil, errorHandler: {(error) in
                            print("Oops! Something went wrong: \(error)")
                        })
                    }
                }
            })
        }
    }
}
