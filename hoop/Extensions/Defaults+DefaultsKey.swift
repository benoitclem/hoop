//
//  Defaults+DefaultsKey.swift
//  hoop
//
//  Created by Clément on 17/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

extension DefaultsKey {
    static let me = Key<profile>("meKey")
    static let blocked = Key<[Int]>("blockedUser")
    static let deviceToken = Key<String>("deviceToken")
}
