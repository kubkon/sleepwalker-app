//
//  ViewController.swift
//  sleepwalker-app
//
//  Created by Jakub Konka on 21/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import UIKit
import WatchConnectivity
import os

class ViewController: UIViewController, WCSessionDelegate {
    @IBOutlet weak var xAccLabel: UILabel!
    var session: WCSession?
    var lastTimestamp: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (WCSession.isSupported()) {
            if (session == nil) {
                os_log("Session was nil", log: OSLog.default, type: .debug)
                session = WCSession.default
                session?.delegate = self
                session?.activate()
            }
        } else {
            os_log("WatchConnectivity not supported", log: OSLog.default, type: .info)
            // FIX notify user the app is incompatible with their devices
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            let alertView = UIAlertController(title: "Update required", message: "Your iOS device seems to be incompatible with this app. Please update to the latest iOS.", preferredStyle: .alert)
            alertView.addAction(action)
            present(alertView, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            // FIX notify user that couldn't activate the session between the app and iOS counterpart
            os_log("There was an error when trying to activate WCSession", log: OSLog.default, type: .error, "\(error.localizedDescription)")
            self.session = nil
            return
        }
        switch activationState {
        case WCSessionActivationState.notActivated, WCSessionActivationState.inactive:
            os_log("Session not activated/inactive", log: OSLog.default, type: .info)
            self.session = nil
        case WCSessionActivationState.activated:
            fallthrough
        default:
            os_log("Session activated", log: OSLog.default, type: .info)
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        os_log("Session became inactive", log: OSLog.default, type: .info)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        os_log("Session deactivated", log: OSLog.default, type: .info)
        self.session = nil
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received \(messageData.count) bytes")
        if messageData.count != AccelReading.SIZE_BYTES * Constants.SamplingRate * Constants.SamplingWindow {
            // FIX perhaps throw an error?
            return
        }
        let currentTimestamp = Date.init().timeIntervalSince1970
        if let lastTimestamp = lastTimestamp {
            let duration = currentTimestamp - lastTimestamp
            DispatchQueue.main.async {
                self.xAccLabel.text = String(describing: duration) + "s"
            }
        }
        lastTimestamp = currentTimestamp
        for i in stride(from: 0, to: messageData.count, by: AccelReading.SIZE_BYTES) {
            if let _ = AccelReading.deserialize(fromBytes: Array(messageData[i..<(i + AccelReading.SIZE_BYTES)])) {
                print("Parsing successful")
            }
        }
    }
}
