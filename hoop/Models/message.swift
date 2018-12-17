//
//  message.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class message: Decodable {
    var id: Int?
    var locId: UInt64?
    var expId: Int?
    var dstId: Int?
    var content: String?
    var timestamp: String? // This should not be replace by dates?
    
    enum CodingKeys: String, CodingKey {
        case id
        case locId = "local_id"
        case expId = "id_exp"
        case dstId = "id_dest"
        case content
        case timestamp = "timestamp_sent"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        locId = try values.decode(UInt64.self, forKey: .locId)
        expId = try values.decode(Int.self, forKey: .expId)
        dstId = try values.decode(Int.self, forKey: .dstId)
        content = try values.decode(String.self, forKey: .content)
        timestamp = try values.decode(String.self, forKey: .timestamp)
    }
}
