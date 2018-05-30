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
        if let data = userInfo["data"] {
            if let data = data as? Data {
                if data.count != 2400 {
                    print("Malformed packet received!")
                    return
                }
                let step = 24
                for i in stride(from: 0, to: data.count, by: step) {
                    let reading = AccelReading.fromBytes(Array(data[i..<(i + step)]))
                    print(reading)
                }
            } else {
                print("Data was empty!")
            }
        } else {
            print("No valid data found")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received data: \(messageData.count) bytes")
        if messageData.count != 2400 {
            return
        }
        let step = 24
        for i in stride(from: 0, to: messageData.count, by: step) {
            let reading = AccelReading.fromBytes(Array(messageData[i..<(i + step)]))
            print(reading)
        }
    }
}

