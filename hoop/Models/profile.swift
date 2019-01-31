//
//  profil.swift
//  AnimationTries
//
//  Created by Clément on 26/11/2018.
//  Copyright © 2018 clemounet. All rights reserved.
//

import UIKit

class profile: Decodable, Encodable {
    // Common profile
    var id: Int?
    var name: String?
    var dob: Date?
    var gender: Int?
    var age_min: Int?
    var age_max: Int?
    var description: String?
    var thumb: URL?
    var pictures_urls = [URL]()
    var pictures_images = [UIImage]()
    var sexualOrientation: Int?
    var activeInHoop: Int?
    var hoopLastConnection: Date?
    var commonLikes: [String]?
    // Use for me profil
    var ak_token: String?
    var fb_token: String?
    var fb_profile_alb_id: String?
    var token: String?
    var sharing_code: String?
    var reached_map: Bool?
    var saw_tutorial: Bool?
    var email: String?
    var current_hoop_id: Int?
    var current_displayed_status: Bool!
    var current_active_hoop_ids = [Int]()
    var current_inactive_hoop_ids = [Int]()
    var n_remaining_conversations: Int?
    
    var age: Int? {
        get {
            if let lDob = dob {
                return lDob.age()
            } else {
                return nil
            }
        }
    }

    var fullTitle: String? {
        get {
            if let lAge = age, let lName = name {
                return "\(lName) \(lAge)"
            } else {
                return nil
            }
        }
    }
    
    var age_yyyymmdd: String? {
        get {
            if let lDob = dob {
                let df = DateFormatter.init()
                df.dateFormat = "yyyy-MM-dd"
                return df.string(from: lDob)
            } else {
                return nil
            }
        }
    }
    
    var lastConnectionString: String? {
        get {
            if let lastConnection = hoopLastConnection {
                var nUnit: Int!
                var tUnit: String!
                let diff = abs(lastConnection.timeIntervalSinceNow)
                if(diff > 24*3600) {
                    // jours
                    nUnit = Int(diff / (24 * 3600))
                    if(nUnit >= 2) {
                        tUnit = "jours"
                    } else {
                        tUnit = "jour"
                    }
                } else if (diff > 3600){
                    // Hour
                    nUnit = Int(diff / 3600)
                    if(nUnit >= 2) {
                        tUnit = "heures"
                    } else {
                        tUnit = "heure"
                    }
                } else if (diff > 60) {
                    // min
                    nUnit = Int(diff / 60)
                    if(nUnit >= 2) {
                        tUnit = "mins"
                    } else {
                        tUnit = "min"
                    }
                } else {
                    // sec
                    nUnit = Int(diff)
                    if(nUnit >= 2) {
                        tUnit = "secs"
                    } else {
                        tUnit = "sec"
                    }
                }
                // Set Profile Info
                return "Actif il y a \(nUnit!) \(tUnit!)"
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
        case age_min
        case age_max
        case description
        case email
        case thumb = "profile_picture_thumb"
        case pictures_urls
        case pictures_images
        case picture1 = "profile_picture"
        case picture2 = "profile_picture2"
        case picture3 = "profile_picture3"
        case picture4 = "profile_picture4"
        case picture5 = "profile_picture5"
        case sexualOrientation = "sexualorientation_id"
        case activeInHoop = "active_in_hoop"
        case hoopLastConnection = "timestamp_lastconnection"
        case commonLikes = "common_likes"
        case ak_token
        case fb_token
        case fb_profile_alb_id
        case token
        case sharing_code
        case reached_map
        case saw_tutorial
        case n_remaining_conversations
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
        if container.contains(.age_min){
            age_min = try? container.decode(Int.self, forKey: .age_min)
        }
        if container.contains(.age_max){
            age_max = try? container.decode(Int.self, forKey: .age_max)
        }
        if container.contains(.gender){
            gender = try? container.decode(Int.self, forKey: .gender)
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
        if let pics_img = try? container.decode([UIImage].self, forKey: .pictures_images) {
            pictures_images += pics_img
        }
        if let pics = try? container.decode([URL].self, forKey: .pictures_urls) {
            pictures_urls += pics
        }
        if let pic1 = try? container.decode(URL.self, forKey: .picture1) {
            pictures_urls.append(pic1)
        }
        if let pic2 = try? container.decode(URL.self, forKey: .picture2) {
            pictures_urls.append(pic2)
        }
        if let pic3 = try? container.decode(URL.self, forKey: .picture3) {
            pictures_urls.append(pic3)
        }
        if let pic4 = try? container.decode(URL.self, forKey: .picture4) {
            pictures_urls.append(pic4)
        }
        if let pic5 = try? container.decode(URL.self, forKey: .picture5) {
            pictures_urls.append(pic5)
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
        if container.contains(.fb_profile_alb_id){
            fb_profile_alb_id = try? container.decode(String.self, forKey: .fb_profile_alb_id)
        }
        if container.contains(.ak_token){
            ak_token = try? container.decode(String.self, forKey: .ak_token)
        }
        if container.contains(.fb_token){
            fb_token = try? container.decode(String.self, forKey: .fb_token)
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
        if container.contains(.n_remaining_conversations){
            n_remaining_conversations = try? container.decode(Int.self, forKey: .n_remaining_conversations)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(dob, forKey: .dob)
        try container.encode(email, forKey: .email)
        try container.encode(age_min, forKey: .age_min)
        try container.encode(age_max, forKey: .age_max)
        try container.encode(gender, forKey: .gender)
        try container.encode(description, forKey: .description)
        try container.encode(thumb, forKey: .thumb)
        try container.encode(pictures_urls, forKey: .pictures_urls)
        try container.encode(pictures_images, forKey: .pictures_images)
        try container.encode(sexualOrientation, forKey: .sexualOrientation)
        try container.encode(activeInHoop, forKey: .activeInHoop)
        try container.encode(hoopLastConnection, forKey: .hoopLastConnection)
        try container.encode(commonLikes, forKey: .commonLikes)
        try container.encode(fb_profile_alb_id, forKey: .fb_profile_alb_id)
        try container.encode(ak_token, forKey: .ak_token)
        try container.encode(fb_token, forKey: .fb_token)
        try container.encode(token, forKey: .token)
        try container.encode(sharing_code, forKey: .sharing_code)
        try container.encode(reached_map, forKey: .reached_map)
        try container.encode(saw_tutorial, forKey: .saw_tutorial)
        try container.encode(n_remaining_conversations, forKey: .n_remaining_conversations)
    }
    
    func update(with profile:profile) {
        age_min = profile.age_min
        age_max = profile.age_max
        description = profile.description
        thumb = profile.thumb
        pictures_urls = profile.pictures_urls
        pictures_images = profile.pictures_images
        sexualOrientation = profile.sexualOrientation
        commonLikes = profile.commonLikes
    }
}

extension profile {
    
    func getProfilePicturesForUpload() -> [String:Any]{
        var data = [String:Any]()
        for i in 0...4 {
            if (i < self.pictures_images.count) {
                // Set the profiles images
                if(i == 0) {
                    data["profile_picture"] = self.pictures_images[i].pngData()
                } else {
                    data["profile_picture\(i+1)"] = self.pictures_images[i].pngData()
                }
            } else {
                // Reset the profiles images
                if(i == 0){
                    data["remove_profile_picture"] = "1"
                } else {
                    data["remove_profile_picture\(i+1)"] = "1"
                }
            }
        }
        return data
    }
    
    func getProfileDataForUpload() -> [String:Any] {
        var data = [String:Any]()
        if let email = self.email {
            data["email"] = email
        }
        if let nick = self.name {
            data["nickname"] = nick
        }
        if let desc = self.description {
            data["description"] = desc
        }
        if let sexOri = self.sexualOrientation {
            data["sexualorientation_id"] = String(sexOri)
        }
        if let age_min = self.age_min {
            data["age_min"] = String(age_min)
        }
        if let age_max = self.age_max {
            data["age_max"] = String(age_max)
        }
        if let birth = self.age_yyyymmdd {
            data["birthday"] = birth
        }
        if let gender = self.gender {
            data["gender_id"] = String(gender)
        }
        return data
    }
    
    func save() {
        let defaults = Defaults()
        defaults.set(self, for: .me)
    }
    
    static func get() -> profile? {
        let defaults = Defaults()
        return defaults.get(for: .me)
    }
}

class profileManager: Codable {
    var profiles = [profile]()
    
    func save() {
        let defaults = Defaults()
        defaults.set(self, for: .profiles)
    }
    
    static func get() -> profileManager? {
        let defaults = Defaults()
        return defaults.get(for: .profiles)
    }
    
    func update(withProfiles profiles: [profile]) {
        for profile in profiles {
            update(withProfile: profile)
        }
    }
    
    func update(withProfile profile: profile) {
        if let index = profiles.index(where: { $0.id == profile.id}) {
            let existingProfile = profiles[index]
            existingProfile.update(with: profile)
        } else {
            profiles.append(profile)
        }
    }
    
    func getProfile(with id: Int) -> profile?{
        return profiles.first(where: { $0.id == id} )
    }
    
}
