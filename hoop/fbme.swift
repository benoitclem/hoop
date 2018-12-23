//
//  fbme.swift
//  hoop
//
//  Created by Clément on 21/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class albumEntry: Decodable {
    var type: String?
    var id: String?
}

class albums: Decodable {
    var data: [albumEntry]
}

class pictureEntry: Decodable {
    var height: Int?
    var width: Int?
    var is_silhouette: Bool?
    var url: URL?
}

class picture: Decodable {
    var data : [pictureEntry]
}

class fbme: Decodable {
    var id: String?
    var gender: String?
    var email: String?
    var first_name: String?
    var birthday: Date?
    var albums: albums?
    var picture: picture
}
