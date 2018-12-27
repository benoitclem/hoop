//
//  fbme.swift
//  hoop
//
//  Created by Clément on 21/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation
import FacebookCore

class AlbumEntry: Decodable {
    var type: String?
    var id: String?
}

class Albums: Decodable {
    var data: [AlbumEntry]
}

class PictureEntry: Decodable {
    var height: Int?
    var width: Int?
    var is_silhouette: Bool?
    var url: URL?
}

class Picture: Decodable {
    var data : PictureEntry
}

class fbme: Decodable {
    var id: String?
    var gender: String?
    var email: String?
    var first_name: String?
    var birthday: Date?
    var albums: Albums?
    var picture: Picture?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gender
        case email
        case first_name
        case birthday
        case albums
        case picture
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if values.contains(.id){
            id = try values.decode(String.self, forKey: .id)
        }
        if values.contains(.gender){
            gender = try values.decode(String.self, forKey: .gender)
        }
        if values.contains(.email){
            email = try values.decode(String.self, forKey: .email)
        }
        if values.contains(.first_name){
            first_name = try values.decode(String.self, forKey: .first_name)
        }
        if values.contains(.birthday){
            let dobstring = try values.decode(String.self, forKey: .birthday)
            let dobformatter = DateFormatter.ddMMyyyy
            if let date = dobformatter.date(from: dobstring) {
                birthday = date
            } else {
                throw DecodingError.dataCorruptedError(forKey: .birthday,
                                                       in: values,
                                                       debugDescription: "Date string does not match format expected by formatter.")
            }
        }
        if values.contains(.albums){
            albums = try values.decode(Albums.self, forKey: .albums)
        }
        if values.contains(.picture){
            picture = try values.decode(Picture.self, forKey: .picture)
        }
    }
    
    var signUpData:[String: Any] {
        get {
            var array = [String: Any]()
            // Store the id
            if let lId = self.id {
                array["fb_id"] = lId
            }
            if let token = AccessToken.current {
                array["token_fb"] = token.authenticationToken
            }
            // Store the nickname
            if let lNickname = self.first_name {
                array["nickname"] = lNickname
            }
            // Store the email
            if let lEmail = self.email {
                array["email"] = lEmail
            }
            // Store the gender
            if let lGender = self.gender {
                if lGender == "male" {
                    array["gender_id"] = "1"
                } else if lGender == "female" {
                    array["gender_id"] = "2"
                }
            }
            // Store the birthday
            if let lBirthday = self.birthday {
                let dobformatter = DateFormatter.yyyyMMdd
                array["birthday"] = dobformatter.string(from: lBirthday)
            }
            return array
        }
    }

}
