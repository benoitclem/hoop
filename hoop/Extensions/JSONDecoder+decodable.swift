//
//  JSONDecoder+decodable.swift
//  hoop
//
//  Created by Clément on 27/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Alamofire

extension JSONDecoder {
    func decodeResponse<T: Decodable>(from response: DataResponse<Data>) -> Result<T> {
        guard response.error == nil else {
            print(response.error!)
            return .failure(response.error!)
        }
        
        guard let responseData = response.data else {
            print("didn't get any data from API")
            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":response.response ?? "unknown"])
            return .failure(error)
        }
        
        do {
            let item = try decode(T.self, from: responseData)
            return .success(item)
        } catch {
            print("error trying to decode response")
            print(error)
            return .failure(error)
        }
    }
}
