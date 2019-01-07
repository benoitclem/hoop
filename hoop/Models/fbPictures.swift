//
//  fbPictures.swift
//  hoop
//
//  Created by Clément on 03/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation
import FacebookCore

class Picture: Decodable {
    var height: Int?
    var width: Int?
    var source: URL?
}

class Pictures: Decodable {
    var images: [Picture]
}

class PicturesAlbum: Decodable {
    var data: [Pictures]
}
