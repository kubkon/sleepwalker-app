//
//  ViewController.swift
//  sleepwalker-app
//
//  Created by Jakub Konka on 21/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var xAccLabel: UILabel!
    var session: WCSession?
    var lastTimestamp: TimeInterval?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (WCSession.isSupported()) {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activated? \(activationState)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received \(messageData.count) bytes")
        if messageData.count != AccelReading.SIZE_BYTES * 100 {
            // FIX perhaps throw an error?
            return
        }
        let currentTimestamp = Date.init().timeIntervalSince1970
        if let lastTimestamp = lastTimestamp {
            let duration = currentTimestamp - lastTimestamp
            xAccLabel.text = String(describing: duration) + "s"
        }
        lastTimestamp = currentTimestamp
        for i in stride(from: 0, to: messageData.count, by: AccelReading.SIZE_BYTES) {
            if let _ = AccelReading.deserialize(fromBytes: Array(messageData[i..<(i + AccelReading.SIZE_BYTES)])) {
                print("Parsing successful")
            }
        }
    }
}
