//
//  fbme.swift
//  hoop
//
//  Created by Clément on 21/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation
import FacebookCore

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
