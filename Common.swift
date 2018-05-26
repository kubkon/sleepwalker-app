//
//  Common.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 24/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation

struct AccelReading {
    var x : Double
    var y : Double
    var z : Double
    
    init(fromX x: Double, fromY y: Double, fromZ z: Double) {
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
    
    static func fromBytes(_ bytes: [Byte]) -> AccelReading {
        // FIX error handling
        let x = unpack(Array(bytes[0..<8]), Double.self)
        let y = unpack(Array(bytes[8..<16]), Double.self)
        let z = unpack(Array(bytes[16...]), Double.self)
        return AccelReading(fromX: x, fromY: y, fromZ: z)
    }
}
