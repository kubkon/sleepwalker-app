//
//  Bytes.swift
//  sleepwalker-app WatchKit Extension
//
//  Created by Jakub Konka on 24/05/2018.
//  Copyright © 2018 Jakub Konka. All rights reserved.
//

import Foundation

typealias Byte = UInt8

func pack<T>(_ value: T) -> [Byte] {
    var value = value
    return withUnsafePointer(to: &value) {
        $0.withMemoryRebound(to: Byte.self, capacity: MemoryLayout<T>.size) {
            Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
        }
    }
}

func unpack<T>(_ value: [Byte], _: T.Type) -> T {
    return value.withUnsafeBufferPointer {
        $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
            $0.pointee
        }
    }
}
