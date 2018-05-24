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
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("Received data!")
    }
}

