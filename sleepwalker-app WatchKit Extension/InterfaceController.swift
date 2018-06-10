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
import os

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var startRecordingButton: WKInterfaceButton!
    var session : WCSession?
    var sessionHandler: (() -> Void)?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        sessionHandler = self.noWCConnectivity
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if (WCSession.isSupported()) {
            if (session == nil) {
                os_log("Session was nil", log: OSLog.default, type: .debug)
                // session not activated yet
                session = WCSession.default
                session?.delegate = self
                session?.activate()
            }
        } else {
            os_log("WatchConnectivity not supported", log: OSLog.default, type: .info)
            // FIX notify user the app is incompatible with their devices
            let action = WKAlertAction.init(title: "OK", style: WKAlertActionStyle.default, handler: {})
            presentAlert(withTitle: "Update required",
                         message: "Your AppleWatch seems to be incompatible with this app. Please update to the latest WatchOS.",
                         preferredStyle: WKAlertControllerStyle.alert,
                         actions: [action])
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func startRecordingButtonTapped() {
        os_log("startRecordingButton pressed", log: OSLog.default, type: .debug)
        if let f = sessionHandler { f() }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            // FIX notify user that couldn't activate the session between the app and iOS counterpart
            os_log("There was an error when trying to activate WCSession", log: OSLog.default, type: .error, "\(error.localizedDescription)")
            self.session = nil
            sessionHandler = noWCConnectivity
            return
        }
        switch activationState {
        case WCSessionActivationState.notActivated, WCSessionActivationState.inactive:
            os_log("Session not activated/inactive", log: OSLog.default, type: .info)
            self.session = nil
            sessionHandler = noWCConnectivity
        case WCSessionActivationState.activated:
            fallthrough
        default:
            os_log("Session activated", log: OSLog.default, type: .info)
            sessionHandler = startStopRecording
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if (session.isReachable) { sessionHandler = startStopRecording }
        else { sessionHandler = noWCConnectivity }
    }
    
    func startStopRecording() {
        os_log("Start recording...", log: OSLog.default, type: .info)
    }
    
    func noWCConnectivity() {
        os_log("No WC connectivity available", log: OSLog.default, type: .info)
        // FIX inform user no WC connectivity with iOS counterpart
        let action = WKAlertAction.init(title: "OK", style: WKAlertActionStyle.default, handler: {})
        presentAlert(withTitle: "No connection",
                     message: "Could not connect to iOS app. Make sure the SleepWalker app is running on your iPhone.",
                     preferredStyle: WKAlertControllerStyle.alert,
                     actions: [action])
    }
}
