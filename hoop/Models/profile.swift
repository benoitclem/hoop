//
//  profil.swift
//  AnimationTries
//
//  Created by Clément on 26/11/2018.
//  Copyright © 2018 clemounet. All rights reserved.
//

import UIKit

class profile: Decodable {
    var id: Int?
    var name: String?
    var dob: Date?
    var age: Int?
    var description: String?
    var thumb: URL?
    var pictures = [URL]()
    var sexualOrientation: Int?
    var activeInHoop: Int?
    var hoopLastConnection: Date?
    var commonLikes: [String]?
    
    enum CodingKeys : String, CodingKey {
        case id
        case name = "nickname"
        case dob = "birthday"
        case description
        case thumb = "profile_picture_thumb"
        case picture1 = "profile_picture"
        case picture2
        case picture3
        case picture4
        case picture5
        case sexualOrientation = "sexualorientation_id"
        case activeInHoop = "active_in_hoop"
        case hoopLastConnection = "timestamp_lastconnection"
        case commonLikes = "common_likes"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        let dobstring = try values.decode(String.self, forKey: .dob)
        let dobformatter = DateFormatter.yyyyMMdd
        if let date = dobformatter.date(from: dobstring) {
            dob = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .dob,
                                                   in: values,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        description = try values.decode(String.self, forKey: .description)
        thumb = try values.decode(URL.self, forKey: .thumb)
        if let pic1 = try? values.decode(URL.self, forKey: .picture1) {
            pictures.append(pic1)
        }
        if let pic2 = try? values.decode(URL.self, forKey: .picture2) {
            pictures.append(pic2)
        }
        if let pic3 = try? values.decode(URL.self, forKey: .picture3) {
            pictures.append(pic3)
        }
        if let pic4 = try? values.decode(URL.self, forKey: .picture4) {
            pictures.append(pic4)
        }
        if let pic5 = try? values.decode(URL.self, forKey: .picture5) {
            pictures.append(pic5)
        }
        sexualOrientation = try values.decode(Int.self, forKey: .sexualOrientation)
        activeInHoop = try values.decode(Int.self, forKey: .activeInHoop)
        
        let hoopLastConnectionString = try values.decode(String.self, forKey: .hoopLastConnection)
        let lcformatter = DateFormatter.yyyyMMddHHmmss
        if let date = lcformatter.date(from: hoopLastConnectionString) {
            hoopLastConnection = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .hoopLastConnection,
                                                   in: values,
                                                   debugDescription: "Date string does not match format expected by formatter.")
        }
        commonLikes = try values.decode([String].self, forKey: .commonLikes)
    }

}
