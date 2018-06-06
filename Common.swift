//
//  Common.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 24/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation

struct AccelReading {
    static var SIZE_BYTES = 24
    
    var x : Double
    var y : Double
    var z : Double
    
    init(_ x: Double,_ y: Double,_ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func toBytes() -> [Byte] {
        let rawX = pack(x)
        let rawY = pack(y)
        let rawZ = pack(z)
        return rawX + rawY + rawZ
    }
    
    static func fromBytes(_ bytes: [Byte]) -> AccelReading? {
        if bytes.count != SIZE_BYTES {
            return nil
        }
        // FIX can unpack throw?
        let x = unpack(Array(bytes[0..<8]), Double.self)
        let y = unpack(Array(bytes[8..<16]), Double.self)
        let z = unpack(Array(bytes[16...]), Double.self)
        return AccelReading(x, y, z)
    }
}

struct Reading {
    static var SIZE_BYTES = 8 + AccelReading.SIZE_BYTES
    
    var timestamp: TimeInterval
    var accelerometer: AccelReading
    // FIX add heart rate and others
    
    init(_ timestamp: TimeInterval,_ accelerometer: AccelReading) {
        self.timestamp = timestamp
        self.accelerometer = accelerometer
    }
    
    func toBytes() -> [Byte] {
        let rawTs = pack(timestamp)
        let rawAccel = accelerometer.toBytes()
        return rawTs + rawAccel
    }
    
    static func fromBytes(_ bytes: [Byte]) -> Reading? {
        if bytes.count != SIZE_BYTES {
            return nil
        }
        // FIX can unpack throw?
        let ts = unpack(Array(bytes[0..<8]), Double.self)
        guard let accelerometer = AccelReading.fromBytes(Array(bytes[8...])) else {
            return nil
        }
        return Reading(ts, accelerometer)
    }
}
