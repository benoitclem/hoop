//
//  hoop.swift
//  AnimationTries
//
//  Created by Clément on 26/11/2018.
//  Copyright © 2018 clemounet. All rights reserved.
//

import UIKit
import MapKit

class hoop: Decodable {
    var id: Int?
    var name: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Int?
    var periphery: Int?
    var profiles: [profile]?
    var active: Int?
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case latitude = "lat"
        case longitude = "lon"
        case radius
        case periphery
        case profiles
        case active
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        if let strLatitude = try? values.decode(String.self, forKey: .latitude) {
            latitude = Double(strLatitude)
        }
        if let strLongitude = try? values.decode(String.self, forKey: .longitude) {
            longitude = Double(strLongitude)
        }
        radius = try values.decode(Int.self, forKey: .radius)
        periphery = try values.decode(Int.self, forKey: .periphery)
        active = try values.decode(Int.self, forKey: .active)
        
    }

}

extension hoop {
    static func == (lhs :hoop, rhs :hoop) -> Bool {
        if let lhs_id = lhs.id, let rhs_id = rhs.id {
            return lhs_id == rhs_id
        } else {
            return false
        }
    }
}
