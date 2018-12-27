//
//  response.swift
//  hoop
//
//  Created by Clément on 27/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation

class hoopApiResponse: Decodable {
    var code: String?
    var message: String?
    var data: Data?
}
