//
//  faqEntry.swift
//  hoop
//
//  Created by Clément on 03/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

class faqEntry: Decodable {
    var id: Int?
    var name: String?
    var content: String?
    var position: Int?
    var active: Int?
}

