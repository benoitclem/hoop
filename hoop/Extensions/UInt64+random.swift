//
//  UInt64+random.swift
//  hoop
//
//  Created by Clément on 23/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

extension UInt64 {
    static func random64(upper_bound: UInt64 = 99999999999) -> UInt64{
        // Generate 64-bit random number:
        var rnd : UInt64 = 0
        arc4random_buf(&rnd, MemoryLayout.size(ofValue: rnd))
        return rnd % upper_bound
    }
}
