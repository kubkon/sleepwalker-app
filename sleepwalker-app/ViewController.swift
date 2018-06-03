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
    @IBOutlet weak var yAccLabel: UILabel!
    @IBOutlet weak var zAccLabel: UILabel!
    var session: WCSession?
    
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
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("Received user info")
        guard let rawTimestamp = userInfo["timestamp"], let rawData = userInfo["data"] else {
            print("No valid data found")
            return
        }
        guard let timestamp = rawTimestamp as? TimeInterval else {
            print("Couldn't parse timestamp")
            return
        }
        guard let data = rawData as? Data else {
            print("Couldn't parse data")
            return
        }
        if data.count != 2400 {
            print("Malformed packet received!")
            return
        }
        let step = 24
        var count = 0
        for i in stride(from: 0, to: data.count, by: step) {
            let reading = AccelReading.fromBytes(Array(data[i..<(i + step)]))
            print(timestamp + (Double(count) * 0.1), reading)
            count += 1
        }
    }
}

