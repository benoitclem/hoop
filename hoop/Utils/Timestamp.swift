//
//  Timestamp.swift
//  hoop
//
//  Created by Clément on 08/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

var Timestamp: TimeInterval {
    return NSDate().timeIntervalSince1970 * 1000
}
