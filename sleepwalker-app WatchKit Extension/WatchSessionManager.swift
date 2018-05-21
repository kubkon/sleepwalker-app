//
//  WatchSessionManager.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 21/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedManager = WatchSessionManager()
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    fileprivate var validSession: WCSession? {
#if os(iOS)
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
#else
        return session
#endif
    }
    
    private override init() {
        super.init()
    }
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
}
