//
//  Dictionnary+Plus.swift
//  hoop
//
//  Created by Clément on 14/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}
