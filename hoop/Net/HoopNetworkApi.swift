//
//  hoopNetApi.swift
//  hoop
//
//  Created by Clément on 10/03/2017.
//  Copyright © 2017 cbenoitp. All rights reserved.
//

import Foundation
import Futures
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class HoopNetworkApi: AlamofireWrapper {
    
    static let API_ERROR_UNKNOWN: Int = 0
    static let API_ERROR_URL_NOT_DEFINED: Int = -1
    static let API_ERROR_DATA_NOT_HANDLED: Int = -2
    static let API_ERROR_APP_ERROR: Int = -3
    static let API_ERROR_NETWORK_ERROR: Int = -4
    static let API_ERROR_MALFORMED_JSON: Int = -5
    static let API_ERROR_DECODER_FAILED: Int = -6
    static let API_ERROR_NO_DATA: Int = -7
    
    // The singleton
    static let sharedInstance = HoopNetworkApi()
    
    // Store connection infos
    static var lastLocation: CLLocation!
    var appToken: String?
    var deviceToken: String?
    

    private init(){
        print("init hoopNetApi")
        super.init(with: "hoopNetworkConfig")
    }
    
    func setDeviceToken(tokenString: String) {
        self.deviceToken = tokenString
    }
    
    private func request<T>(with method: String,and arguments: [String:String]) -> Future<hoopApiResponse<T>> {
        let promise = Promise<hoopApiResponse<T>>()
        if(self.baseUrl !=  nil) {
            let fullUrl = "https://\(self.baseUrl!)/api/\(method)?\(self.urlEncode(arguments))"
            //print(fullUrl)
            Alamofire.request(fullUrl).responseData { response in
                /*
                 print(response.request)  // original URL request
                 print(response.response) // HTTP URL response
                 print(response.data)     // server data
                 print(response.result)   // result of response serialization
                 */
                let decoder = JSONDecoder()
                let result: Result<hoopApiResponse<T>> = decoder.decodeResponse(from: response)
                print(result)
            }
        } else {
            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_URL_NOT_DEFINED, userInfo: ["desc":"base url not defined, please set hoopNetworkConfig/baseUrl key in plist file"])
            promise.reject(error)
        }
        return promise.future
    }
    
//    private func request(with method: String,and arguments: [String:String]) -> Future<JSON> {
//        let promise = Promise<JSON>()
//        if(self.baseUrl !=  nil) {
//            let fullUrl = "https://\(self.baseUrl!)/api/\(method)?\(self.urlEncode(arguments))"
//            //print(fullUrl)
//            Alamofire.request(fullUrl).responseJSON { response in
//                /*
//                 print(response.request)  // original URL request
//                 print(response.response) // HTTP URL response
//                 print(response.data)     // server data
//                 print(response.result)   // result of response serialization
//                 */
//                if((response.result.value) != nil) {
//                    let jsonData = JSON(response.result.value!)
//                    promise.fulfill(jsonData)
//                } else {
//                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_UNKNOWN, userInfo: ["desc":response.response ?? "unknown"])
//                    promise.reject(error)
//                }
//            }
//        } else {
//            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_URL_NOT_DEFINED, userInfo: ["desc":"base url not defined, please set hoopNetworkConfig/baseUrl key in plist file"])
//            promise.reject(error)
//        }
//        return promise.future
//    }
    
    private func post<T>(with methodName: String, and arguments: [String:Any], andProgress progressHandler: ((_ result: Double) -> Void)? ) -> Future<hoopApiResponse<T>> {
        let promise = Promise<hoopApiResponse<T>>()
        if(self.baseUrl !=  nil) {
            // Build request
            let fullUrl = "https://\(self.baseUrl!)/api/\(methodName)"
            // Do the request
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    for (key,arg) in arguments {
                        if(arg != nil) {
                            // Add image
                            if (arg is Data) {
                                multipartFormData.append(arg as! Data, withName: key, fileName: key + ".png", mimeType: "image/png")
                            } else if (arg is String) {
                                let str = arg as! String
                                multipartFormData.append(str.data(using:String.Encoding.utf8)!, withName: key)
                            } else {
                                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_DATA_NOT_HANDLED, userInfo: ["desc":"Data type not handled"])
                                promise.reject(error)
                            }
                        }
                    }
            },
                to:fullUrl,
                method:.post,
                headers:["Content-Type": "application/x-www-form-urlencoded"],
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseData { response in
                            if let _ = response.result.value {
                                let decoder = JSONDecoder()
                                let result: Result<hoopApiResponse<T>> = decoder.decodeResponse(from: response)
                                switch result {
                                case .success(let data):
                                    if let code = data.code {
                                        if code == "ko" {
                                            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_APP_ERROR, userInfo: ["desc": data.message ?? "unknown"])
                                            promise.reject(error)
                                        } else {
                                            promise.fulfill(data)
                                        }
                                    } else {
                                        let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_DECODER_FAILED, userInfo: ["desc":response.error ?? "unknown"])
                                        promise.reject(error)
                                    }
                                   
                                case .failure(let error):
                                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_MALFORMED_JSON, userInfo: ["desc": error.localizedDescription ])
                                    promise.reject(error)
                                }
                            } else {
                                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NETWORK_ERROR, userInfo: ["desc":response.error ?? "unknown"])
                                promise.reject(error)
                            }
                        }
                        upload.uploadProgress { progress in
                            if(progressHandler != nil) {
                                progressHandler!(progress.fractionCompleted)
                            }
                        }
                    case .failure(let error):
                        let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NETWORK_ERROR, userInfo: ["desc":error.localizedDescription])
                        promise.reject(error)
                    }
            })
        } else {
            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_URL_NOT_DEFINED, userInfo: ["desc":"base url not defined, please set hoopNetworkConfig/baseUrl key in plist file"])
            promise.reject(error)
        }
        return promise.future
    }
    
}

extension HoopNetworkApi {
    
    func signUp(with facebookData: fbme) -> Future<profile> {
        //print("registering new user")
        // Serialize the facebook data
        //jsonData?["data"]["token"].rawString(),jsonData?["data"]["sharing_code"].rawString()
        print(facebookData.signUpData)
        let promise: Future<hoopApiResponse<profile>> = self.post(with: "signUpClient", and: facebookData.signUpData, andProgress: nil)
        return promise.then { response -> Future<profile> in
            let promise =  Promise<profile>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func getHoops(by location: CLLocation) -> Future<[hoop]>? {
        guard let token = self.appToken else {
            return nil
        }
        
        let promise: Future<hoopApiResponse<[hoop]>> = self.request(with: "getLovestopInfoByLatLong",and: ["token":token,"lat":String(location.coordinate.latitude),"long":String(location.coordinate.longitude), "margin":"0.02"])
        return promise.then { data -> Future<[hoop]> in
            let promise =  Promise<[hoop]>()
            let hoopArray = [hoop]()
            promise.fulfill(hoopArray)
            return promise.future
        }
    }
    /*
    func getLoveStopInIds(by location: CLLocationCoordinate2D) -> Future<[Int]> {
        guard let token = self.appToken else {
            return nil
        }
        
        let promise = self.request(with: "getLovestopIn",and: ["token":token,"lat":String(location.latitude),"long":String(location.longitude)])
        return promise.then { json -> Future<[Int]> in
            let promise =  Promise<[Int]>()
            if json["lovestop_id"].exists() {
                var hoopIndexArray = [Int]()
                for (_, subJson) in json["lovestop_id"] {
                    if let hoopIndex = subJson.int {
                        hoopIndexArray.append(hoopIndex)
                    }
                }
                promise.fulfill(hoopIndexArray)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_MALFORMED_JSON, userInfo: ["desc":"lovestop_id not present in ouput"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    */

}


