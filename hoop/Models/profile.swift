//
//  profil.swift
//  AnimationTries
//
//  Created by Clément on 26/11/2018.
//  Copyright © 2018 clemounet. All rights reserved.
//

import UIKit

extension DefaultsKey {
    static let me = Key<profile>("meKey")
}

class profile: Decodable, Encodable {
    // Common profile
    var id: Int?
    var name: String?
    var dob: Date?
    var gender: Int?
    var description: String?
    var thumb: URL?
    var pictures = [URL]()
    var sexualOrientation: Int?
    var activeInHoop: Int?
    var hoopLastConnection: Date?
    var commonLikes: [String]?
    // Use for me profile
    var fb_profile_id: String?
    var token: String?
    var sharing_code: String?
    var reached_map: Bool?
    var saw_tutorial: Bool?
    var email: String?
    
    var age: Int? {
        get {
            if let bday = dob {
                return bday.age()
            } else {
                return nil
            }
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name = "nickname"
        case dobStr = "birthday"
        case dob
        case gender = "gender_id"
        case description
        case email
        case thumb = "profile_picture_thumb"
        case pictures
        case picture1 = "profile_picture"
        case picture2
        case picture3
        case picture4
        case picture5
        case sexualOrientation = "sexualorientation_id"
        case activeInHoop = "active_in_hoop"
        case hoopLastConnection = "timestamp_lastconnection"
        case commonLikes = "common_likes"
        case fb_profile_id
        case token
        case sharing_code
        case reached_map
        case saw_tutorial
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.id){
            id = try? container.decode(Int.self, forKey: .id)
        }
        if container.contains(.name){
            name = try? container.decode(String.self, forKey: .name)
        }
        if container.contains(.dobStr){
            if let dobstring = try? container.decode(String.self, forKey: .dobStr) {
                let dobformatter = DateFormatter.yyyyMMdd
                if let date = dobformatter.date(from: dobstring) {
                    dob = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .dob,
                                                           in: container,
                                                           debugDescription: "Date string does not match format expected by formatter.")
                }
            }
        }
        if container.contains(.dob) {
            dob = try? container.decode(Date.self, forKey: .dob)
        }
        if container.contains(.email){
            email = try? container.decode(String.self, forKey: .email)
        }
        if container.contains(.gender){
            gender = try? container.decode(Int.self, forKey: .gender)
        }
        if container.contains(.description){
            description = try? container.decode(String.self, forKey: .description)
        }
        if container.contains(.thumb){
            thumb = try? container.decode(URL.self, forKey: .thumb)
        }
        if let pic1 = try? container.decode(URL.self, forKey: .picture1) {
            pictures.append(pic1)
        }
        if let pic2 = try? container.decode(URL.self, forKey: .picture2) {
            pictures.append(pic2)
        }
        if let pic3 = try? container.decode(URL.self, forKey: .picture3) {
            pictures.append(pic3)
        }
        if let pic4 = try? container.decode(URL.self, forKey: .picture4) {
            pictures.append(pic4)
        }
        if let pic5 = try? container.decode(URL.self, forKey: .picture5) {
            pictures.append(pic5)
        }
        if container.contains(.sexualOrientation){
            sexualOrientation = try? container.decode(Int.self, forKey: .sexualOrientation)
        }
        if container.contains(.activeInHoop){
            activeInHoop = try? container.decode(Int.self, forKey: .activeInHoop)
        }
        if container.contains(.hoopLastConnection){
            if let hoopLastConnectionString = try? container.decode(String.self, forKey: .hoopLastConnection) {
                let lcformatter = DateFormatter.yyyyMMddHHmmss
                if let date = lcformatter.date(from: hoopLastConnectionString) {
                    hoopLastConnection = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .hoopLastConnection,
                                                           in: container,
                                                           debugDescription: "Date string does not match format expected by formatter.")
                }
            }
        }
        if container.contains(.commonLikes){
            commonLikes = try? container.decode([String].self, forKey: .commonLikes)
        }
        if container.contains(.fb_profile_id){
            fb_profile_id = try? container.decode(String.self, forKey: .fb_profile_id)
        }
        if container.contains(.token){
            token = try? container.decode(String.self, forKey: .token)
        }
        if container.contains(.sharing_code){
            sharing_code = try? container.decode(String.self, forKey: .sharing_code)
        }
        if container.contains(.reached_map) {
            reached_map = try? container.decode(Bool.self, forKey: .reached_map)
        }
        if container.contains(.saw_tutorial) {
            saw_tutorial = try? container.decode(Bool.self, forKey: .saw_tutorial)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dob, forKey: .dob)
        try container.encode(email, forKey: .email)
        try container.encode(gender, forKey: .gender)
        try container.encode(description, forKey: .description)
        try container.encode(thumb, forKey: .thumb)
        try container.encode(pictures, forKey: .pictures)
        try container.encode(sexualOrientation, forKey: .sexualOrientation)
        try container.encode(activeInHoop, forKey: .activeInHoop)
        try container.encode(hoopLastConnection, forKey: .hoopLastConnection)
        try container.encode(commonLikes, forKey: .commonLikes)
        try container.encode(fb_profile_id, forKey: .fb_profile_id)
        try container.encode(token, forKey: .token)
        try container.encode(sharing_code, forKey: .sharing_code)
        try container.encode(reached_map, forKey: .reached_map)
        try container.encode(saw_tutorial, forKey: .saw_tutorial)
    }
}

extension profile {
    func save() {
        let defaults = Defaults()
        defaults.set(self, for: .me)
    }
    
    static func get() -> profile? {
        let defaults = Defaults()
        return defaults.get(for: .me)
    }
}
