//
//  Common.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 24/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation

struct AccelReading : Codable {
    static var SIZE_BYTES = 4 * 8
    
    var timestamp : TimeInterval
    var x : Double
    var y : Double
    var z : Double
    
    init(fromTimestamp timestamp: TimeInterval, fromX x: Double, fromY y: Double, fromZ z: Double) {
        self.timestamp = timestamp
        self.x = x
        self.y = y
        self.z = z
    }
    
    func serialize() -> [Byte] {
        let rawTimestamp = pack(timestamp)
        let rawX = pack(x)
        let rawY = pack(y)
        let rawZ = pack(z)
        return rawTimestamp + rawX + rawY + rawZ
    }
    
    static func deserialize(fromBytes bytes: [Byte]) -> AccelReading? {
        if bytes.count != SIZE_BYTES {
            return nil
        }
        // FIX can unpack throw?
        let timestamp = unpack(Array(bytes[0..<8]), Double.self)
        let x = unpack(Array(bytes[8..<16]), Double.self)
        let y = unpack(Array(bytes[16..<24]), Double.self)
        let z = unpack(Array(bytes[24...]), Double.self)
        return AccelReading(fromTimestamp: timestamp, fromX: x, fromY: y, fromZ: z)
    }
}
