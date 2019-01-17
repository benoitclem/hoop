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
import AlamofireImage
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
    static let API_ERROR_MISSING_DATA: Int = -8
    static let API_ERROR_MISSING_URL: Int = -9
    static let API_ERROR_NO_PROFILE: Int = -10
    static let API_ERROR_NO_IDS: Int = -11
    static let API_ERROR_TOKEN_MISSING: Int = -12
    static let API_ERROR_BLOCKING_ERROR: Int = -13
    static let API_ERROR_BLOCKING_UNKNOWN_ERROR: Int = -14
    
    // The singleton
    static let sharedInstance = HoopNetworkApi()
    
    // Store connection infos
    static var appToken: String?
    
    private init(){
        print("init hoopNetApi")
        super.init(with: "hoopNetworkConfig")
    }
    
    func setDeviceToken(tokenString: String) {
        self.deviceToken = tokenString
    }
    
    private func request<T>(_ method: String,and arguments: [String:String]) -> Future<hoopApiResponse<T>> {
        // Insert token if exists
        var mutableArguments = arguments
        if let token = HoopNetworkApi.appToken {
            mutableArguments["token"] = token
        }
        // Do the request now
        let promise = Promise<hoopApiResponse<T>>()
        if(self.baseUrl !=  nil) {
            let fullUrl = "https://\(self.baseUrl!)/api/\(method)?\(self.urlEncode(mutableArguments))"
            Alamofire.request(fullUrl).responseData { response in
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
            }
        } else {
            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_URL_NOT_DEFINED, userInfo: ["desc":"base url not defined, please set hoopNetworkConfig/baseUrl key in plist file"])
            promise.reject(error)
        }
        return promise.future
    }
    
    func HoopRequest<T: Decodable>(_ method: String, and arguments: [String:String]) -> Future<T> {
        let promise: Future<hoopApiResponse<T>> = self.request(method, and: arguments)
        return promise.then { response -> Future<T> in
            let promise = Promise<T>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    private func post<T>(_ methodName: String, and arguments: [String:Any], andProgress progressHandler: ((_ result: Double) -> Void)? ) -> Future<hoopApiResponse<T>> {
        let promise = Promise<hoopApiResponse<T>>()
        // Insert token if exists
        var mutableArguments = arguments
        if let token = HoopNetworkApi.appToken {
            mutableArguments["token"] = token
        }
        // Do the request now
        if(self.baseUrl !=  nil) {
            // Build request
            let fullUrl = "https://\(self.baseUrl!)/api/\(methodName)"
            // Do the request
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    for (key,arg) in mutableArguments {
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
    
    func getImage(fromUrl url: URL) -> Future<UIImage> {
        let imagePromise = Promise<UIImage>()
        Alamofire.request(url.absoluteString).responseImage { response in
            switch(response.result) {
            case .success(let image):
                imagePromise.fulfill(image)
            case .failure(let error):
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_MISSING_DATA, userInfo: ["desc":error.localizedDescription])
                imagePromise.reject(error)
            }
        }
        return imagePromise.future
    }

    func getImages(fromUrls urls: [URL]) -> Future<[UIImage]> {
        var mutatingUrl = urls
        let imagesPromises = Promise<[UIImage]>()
        var images = [UIImage]()
        // The urls array must contain one URL
        if let firstUrl = mutatingUrl.first {
            mutatingUrl.removeFirst()
            var imageFuture = self.getImage(fromUrl: firstUrl)
            for url in mutatingUrl {
                imageFuture = imageFuture.then { image -> Future<Image> in
                    images.append(image)
                    return self.getImage(fromUrl: url)
                }
            }
            imageFuture.whenFulfilled { image in
                images.append(image)
                imagesPromises.fulfill(images)
            }
        } else {
            let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_MISSING_URL, userInfo: ["desc":"no url array provided"])
            imagesPromises.reject(error)
        }
        return imagesPromises.future
    }
}

extension HoopNetworkApi {
    
    // The signup for account kit
    func signupAK(with akToken: String) -> Future<profile> {
        let akData: [String:Any] = ["fb_id":akToken]
        let promise: Future<hoopApiResponse<profile>> = self.post("signUpClient", and: akData, andProgress: nil)
        return promise.then { response -> Future<profile> in
            let promise =  Promise<profile>()
            if let me = response.data {
                // Save the token and the me data
                if let token = me.token {
                    HoopNetworkApi.appToken = token
                    AppDelegate.me = me
                    me.save()
                    promise.fulfill(me)
                } else {
                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_TOKEN_MISSING, userInfo: ["desc":"singup failed to propose token"])
                    promise.reject(error)
                }
            }
            return promise.future
        }
    }
    
    // The signup for facebook login
    func signUpFb(with facebookData: fbme) -> Future<profile> {
        let promise: Future<hoopApiResponse<profile>> = self.post("signUpClient", and: facebookData.signUpData, andProgress: nil)
        return promise.then { response -> Future<profile> in
            let promise =  Promise<profile>()
            if let me = response.data {
                // if everything goes right transfer fbme infos to profile infos
                // TODO: maybe the fbme should be recorded somewhere if
                // all datas are not copied to profile
                if let name = facebookData.first_name, let dob = facebookData.birthday, let gender = facebookData.gender_id, let email = facebookData.email, let fb_profile_album = facebookData.albums {
                    me.name = name
                    me.dob = dob
                    me.gender = gender
                    me.email = email
                    me.fb_profile_alb_id = fb_profile_album.data.first(where: { $0.type == "profile"})?.id
                    
                    // Save the token and the me data
                    if let token = me.token {
                        HoopNetworkApi.appToken = token
                        AppDelegate.me = me
                        me.save()
                        promise.fulfill(me)
                    } else {
                        let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_TOKEN_MISSING, userInfo: ["desc":"singup failed to propose token"])
                        promise.reject(error)
                    }
                } else {
                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_MISSING_DATA, userInfo: ["desc":"facebook data are erroneous"])
                    promise.reject(error)
                }
            }
            return promise.future
        }
    }
    

    
    // This should be working but not
    func getFaq2() -> Future<[faqEntry]> {
        return HoopRequest("getFaq", and: [:])
    }
 
    func getFaq() -> Future<[faqEntry]>? {
        let promise: Future<hoopApiResponse<[faqEntry]>> = self.request("getFaq", and: [:])
        return promise.then { response -> Future<[faqEntry]> in
            let promise = Promise<[faqEntry]>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func getConditions() -> Future<[condition]>? {
        let promise: Future<hoopApiResponse<[condition]>> = self.request("getTermsAndConditions", and: [:])
        return promise.then { response -> Future<[condition]> in
            let promise = Promise<[condition]>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    // Proxy function that only save images
    func getProfilePictures(fromUrls url: [URL]) -> Future<Bool> {
        return self.getImages(fromUrls: url).then { images -> Future<Bool> in
            let promise = Promise<Bool>()
            if let me = AppDelegate.me {
                me.pictures_images = images
                me.save()
                promise.fulfill(true)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_PROFILE, userInfo: ["desc":"could not get profile in app delegate"])
                promise.reject(error)
            }
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

extension HoopNetworkApi {
    
    func getHoopIn(byLatLong coordinates:CLLocationCoordinate2D) -> Future<[Int]> {
        let future: Future<hoopApiResponse<hoopIn>> = self.request("getLovestopIn", and: ["lat": String(coordinates.latitude),"long":String(coordinates.longitude)])
        return future.then { response -> Future<[Int]> in
            let promise = Promise<[Int]>()
            if (AppDelegate.me?.id == nil) {
                AppDelegate.me?.id = response.data?.client_id
            }
            if let ids = response.data?.hoop_ids {
                promise.fulfill(ids)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_IDS, userInfo: ["desc":"no ids found"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func getHoopInfo(byLatLong coordinates:CLLocationCoordinate2D) -> Future<[hoop]> {
        let future: Future<hoopApiResponse<[hoop]>> = self.request("getLovestopInfoByLatLong", and: ["lat": String(coordinates.latitude),"long":String(coordinates.longitude), "margin":"0.02"])
        return future.then { response -> Future<[hoop]> in
            let promise = Promise<[hoop]>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func getHoopContent(withIds ids:[Int]) -> Future<[String:[profile]]> {
        let strIds = ids.map { String($0) }.joined(separator: ",")
        let future: Future<hoopApiResponse<[String:[profile]]>> = self.request("getLovestopContent", and: ["lovestop_id":strIds])
        return  future.then { response -> Future<[String:[profile]]> in
            let promise = Promise<[String:[profile]]>()
            if let data = response.data {
                promise.fulfill(data)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func postDevice(withDeviceId deviceId:String) -> Future<Bool> {
        let future: Future<hoopApiResponse<String>> = self.post("postDevice", and: ["deviceId":self.deviceToken!,"deviceUuid":""], andProgress: nil)
        return future.then { response -> Future<Bool> in
            let promise = Promise<Bool>()
            if let resultString = response.data {
                if resultString == "device_updated" {
                    promise.fulfill(true)
                } else {
                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_BLOCKING_UNKNOWN_ERROR, userInfo: ["desc":"unknwon blocking error"])
                    promise.reject(error)
                }
                
            }
            return promise.future
        }
    }
    
    func postHoopProfile(withData data:[String:Any]) -> Future<Bool> {
        let future: Future<hoopApiResponse<profile>> = self.post("setClientInfo", and: data, andProgress: nil)
        return future.then { response -> Future<Bool> in
            let promise = Promise<Bool>()
            if let updatedProfile = response.data {
                promise.fulfill(true)
            } else {
                let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_NO_DATA, userInfo: ["desc":"could not extract key 'data' from incoming data"])
                promise.reject(error)
            }
            return promise.future
        }
    }
    
    func postReportClient(byId reportId:Int) -> Future<Bool>  {
        let future: Future<hoopApiResponse<String>> = self.post("postBlockClient", and: ["blockId":String(reportId)], andProgress: nil)
        return future.then { response -> Future<Bool> in
            let promise = Promise<Bool>()
            if let resultString = response.data {
                switch resultString {
                case "client_blocked":
                    promise.fulfill(true)
                case "client_unBlocked":
                    promise.fulfill(false)
                case "client_block_ko":
                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_BLOCKING_ERROR, userInfo: ["desc":"wrong id(\(reportId)"])
                    promise.reject(error)
                default:
                    let error = NSError(domain: "HoopNetworkApiError", code: HoopNetworkApi.API_ERROR_BLOCKING_UNKNOWN_ERROR, userInfo: ["desc":"unknwon blocking error"])
                    promise.reject(error)
                }
                
            }
            return promise.future
        }
    }
    
}
