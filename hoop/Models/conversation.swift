//
//  conversation.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class conversation: Decodable {
    var id: Int?
    var expId: Int?
    var dstId: Int?
    var nickname: String?
    var lastMessage: String?
    var profilePictureUrl: URL?
    var timestampSent: String? // This should not be replace by dates?
    var timestampRead: String? // This should not be replace by dates?
    
    enum CodingKeys : String, CodingKey {
        case id
        case expId = "id_exp"
        case dstId = "id_dest"
        case nickname
        case lastMessage = "last_message"
        case profilePictureUrl = "profile_picture"
        case timestampSent = "timestamp_sent"
        case timestampRead = "timestamp_read"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        nickname = try values.decode(String.self, forKey: .nickname)
        expId = try values.decode(Int.self, forKey: .expId)
        dstId = try values.decode(Int.self, forKey: .dstId)
        lastMessage = try values.decode(String.self, forKey: .lastMessage)
        profilePictureUrl  = try values.decode(URL.self, forKey: .profilePictureUrl)
        timestampSent = try values.decode(String.self, forKey: .timestampSent)
        timestampRead = try values.decode(String.self, forKey: .timestampRead)
    }
    
}




