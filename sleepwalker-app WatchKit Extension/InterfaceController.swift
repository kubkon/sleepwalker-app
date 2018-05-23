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
    var activated = false
    let motionManager = CMMotionManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if (WCSession.isSupported() && !activated) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        activated = true
        WCSession.default.sendMessage(["x" : 0.0, "y" : 0.0, "z" : 0.0], replyHandler: nil)
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 5
            motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                if let data = data {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
//                    print("x:\(x) y:\(y) z:\(z)")
                    
                    WCSession.default.sendMessage(["x" : x, "y" : y, "z" : z], replyHandler: nil)
                }
            })
        }
    }
}
