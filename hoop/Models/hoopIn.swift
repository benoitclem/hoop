//
//  hoopIn.swift
//  hoop
//
//  Created by Clément on 08/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

class hoopIn: Decodable {
    var client_id: Int?
    var hoop_ids: [Int]?
    
    enum CodingKeys : String, CodingKey {
        case client_id
        case hoop_ids = "lovestop_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        client_id = try container.decode(Int.self, forKey: .client_id)
        hoop_ids = try container.decode([Int].self, forKey: .hoop_ids)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(client_id, forKey: .client_id)
        try container.encode(hoop_ids, forKey: .hoop_ids)
    }
}
