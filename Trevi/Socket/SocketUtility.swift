//
//  SocketUtility.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 9..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

#if os(Linux)
    import SwiftGlibc
#else
    import Darwin
#endif

// Get String from the pointer
public func blockToString(block: UnsafePointer<CChar>, length: Int) -> String {
    var idx = block
    var value = "" as String
    
    for _ in 0...length {
        //if idx.memory > 31{
            let c = String(format: "%c", idx.memory)
            value += c
        //}
        idx++
    }
    return value
}

public func blockToUTF8String(block: UnsafePointer<CChar>) -> String {
    let (k,_) = String.fromCStringRepairingIllFormedUTF8(block)
    let value = k! as String
    return value
}

