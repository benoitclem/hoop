//
//  response.swift
//  hoop
//
//  Created by Clément on 27/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation

class hoopApiResponse<T:Decodable>: Decodable {
    var code: String?
    var message: String?
    var data: T?
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try values.decode(String.self, forKey: .code)
        message = try values.decode(String.self, forKey: .message)
        data = try? values.decode(T.self, forKey: .data)
    }
}
