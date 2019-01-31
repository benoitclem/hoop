//
//  FacebookHandler.swift
//  hoop
//
//  Created by Clément on 15/02/2017.
//  Copyright © 2017 cbenoitp. All rights reserved.
//

import UIKit
import Foundation
import FacebookCore
import FacebookLogin
import Futures
import SwiftyJSON

class FacebookHandler: NSObject {
    
    static let FB_ERROR_UNKNOWN: Int = 0
    static let FB_ERROR_BASE:Int = -1
    static let FB_ERROR_CANCELED:Int = -2
    static let FB_ERROR_PERMISSION_DENIED:Int = -3

    static let FB_ERROR_GRAPH_API: Int = -4
    static let FB_ERROR_DECODING_ME: Int = -5
    static let FB_ERROR_MISSING_ALBUM_ID: Int = -6
    
    static func connect(with permission:[ReadPermission],from viewController: UIViewController) -> Future<Bool> {
        let promise = Promise<Bool>()

        let loginManager = LoginManager.init()
        loginManager.logIn(readPermissions: permission, viewController: viewController) { loginResult in
            switch loginResult {
            case .failed(let error):
                loginManager.logOut()
                let hoopError = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_BASE, userInfo: ["desc":error.localizedDescription])
                promise.reject(hoopError)
            case .cancelled:
                loginManager.logOut()
                let hoopError = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_CANCELED, userInfo: ["desc":"user have canceled procedure"])
                promise.reject(hoopError)
            case .success(let _, let declinedPermissions, let _):
                if !declinedPermissions.isEmpty {
                    loginManager.logOut()
                    let hoopError = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_PERMISSION_DENIED, userInfo: ["desc":"user declined important permissions"])
                    promise.reject(hoopError)
                } else {
                    promise.fulfill(true)
                }
            }
        }
        
        return promise.future
    }
    
    static func logout() {
        // Do the facebook logout
        let loginManager = LoginManager.init()
        loginManager.logOut()
    }
    
    static func isFbConnected() -> Bool {
        // Update token here
        if let _ = AccessToken.current {
            return true
        } else {
            return false
        }
    }
    
    static func allPermissionGranted() -> Bool? {
        return AccessToken.current?.declinedPermissions?.isEmpty
    }
    
    static func getMissingFacebookParameters() -> String{
        // Create a nice composed string
        var parametersFields: [String] = []
        if UserDefaults.standard.value(forKey:"id") == nil {
            parametersFields.append("id")
        }
        if UserDefaults.standard.value(forKey:"gender") == nil {
            parametersFields.append("gender")
        }
        if UserDefaults.standard.value(forKey:"email") == nil {
            parametersFields.append("email")
        }
        if UserDefaults.standard.value(forKey:"first_name") == nil {
            parametersFields.append("first_name")
        }
        if UserDefaults.standard.value(forKey:"birthday") == nil {
            parametersFields.append("birthday")
        }
        if UserDefaults.standard.value(forKey: "fbProfileAlbumId") == nil {
            parametersFields.append("albums{type}")
        }
        if UserDefaults.standard.value(forKey:"fbPictureData") == nil {
            parametersFields.append("picture.width(800).height(800)")
        }
        return parametersFields.joined(separator: ",")
    }
    

//
//    static func synchronizeFacebookBaseParameters(completionHandler:@escaping (_ message: String)->Void, errorHandler: @escaping(_ message: String)->Void) -> Bool {
//        let userDefaults = UserDefaults.standard
//        // Get a string with the wanted parameters
//        let parametersFields = self.getMissingFacebookParameters()
//        // If the string is empty, it means that no synch is need
//        if(parametersFields.compare("") != ComparisonResult.orderedSame) {
//            // Format the request parameter filed
//            let parameters = ["fields": parametersFields]
//            // Do the request within the /me node
//            GraphRequest.init(graphPath: "me", parameters: parameters)
//                .start(completionHandler: { (_, result, error) in
//                    if(error != nil){
//                        //print(error)
//                        errorHandler("Got An error")
//                    } else {
//                        let myresults = result as! [String:Any]
//
//                        // just a little print to see what's we got in the result array
//                        /*for k in myresults.keys {
//                         print(k)
//                         print(myresults[k])
//                         }*/
//
//                        print(myresults)
//
//                        if let id = myresults["id"] {
//                            userDefaults.set(id as!String, forKey: "id")
//                        }
//
//                        if let gender = myresults["gender"] {
//                            userDefaults.set(gender as!String, forKey: "gender")
//                        }
//
//                        if let email = myresults["email"] {
//                            userDefaults.set(email as!String, forKey: "email")
//                        }
//
//                        if let fname = myresults["first_name"] {
//                            userDefaults.set(fname as!String, forKey: "first_name")
//                        }
//
//                        if let bday = myresults["birthday"] {
//                            print(">>>> \(bday)")
//                            userDefaults.set(bday as!String, forKey: "birthday")
//                        }
//
//                        if let _picStruct = myresults["picture"] {
//                            let picStruct = _picStruct as! [String:[String:Any]]
//                            userDefaults.set(picStruct["data"]?["url"] as!String, forKey: "fbPictureUrl")
//
//                            // Test this in poor network condition
//                            let url = URL(string: picStruct["data"]?["url"] as! String)
//                            let data = try? Data.init(contentsOf: url!)
//                            if(data != nil){
//                                userDefaults.set(data as Any, forKey:"fbPictureData")
//                            }
//                        }
//
//                        if let _albStruct = myresults["albums"] {
//                            let albresStruct =  _albStruct as! [String:Any?]
//                            if let data = albresStruct["data"] as? [[String:String]] {
//                                for album in data {
//                                    //print(album["type"]!,album["id"]!)
//                                    if(album["type"]! == "profile") {
//                                        userDefaults.set(album["id"]! as Any, forKey:"fbProfileAlbumId")
//                                        break
//                                    }
//                                }
//                            }
//                        }
//
//                        // commit to user default
//                        userDefaults.synchronize()
//
//                        // Tell we have all basic info
//                        UserDefaults.standard.set(true, forKey: "basicInfo")
//
//                        completionHandler("Completed Synchronize")
//                    }
//                })
//            // get likes?
//            return true
//        } else {
//            // Did not synchonize
//            completionHandler("Completed Synchronize")
//            return false
//        }
//    }
    
    // Likes stuffs
    
//    static func synchronizeFacebookLikes(completionHandler:@escaping (_ likeArray: [[String:String]]) -> Void) -> Void {
//        self.getLikes(withAfterCursor: nil, completionHandler: completionHandler)
//    }
//
//    static func getLikes(withAfterCursor afterCursor: String?,completionHandler:@escaping (_ likeArray: [[String:String]])->Void){
//        var p = [String: String]()
//        if let cursor = afterCursor {
//            p["after"] = cursor
//        }
//        // Do the request to /me/likes node
//        FBSDKGraphRequest.init(graphPath: "me/likes", parameters: p)
//            .start(completionHandler: {(_, result, error) in
//                if(result != nil) {
//                    var userLikes = [[String:String]]()
//                    let dictResult = result as! [String:Any?]
//
//                    if let data = dictResult["data"] as? [[String:String]] {
//                        for entry in data {
//                            userLikes.append(["id":entry["id"]!,"name":entry["name"]!])
//                        }
//                    }
//                    if let paging = dictResult["paging"] as? [String:Any?] {
//                        if let cursors = paging["cursors"] as? [String:String] {
//                            if let afterCursor = cursors["after"] {
//                                //print("cursor",afterCursor)
//                                self.getLikes(withAfterCursor: afterCursor, completionHandler: { array  in
//                                    completionHandler(array + userLikes)
//                                })
//                            }
//                        }
//                    } else {
//                        completionHandler(userLikes)
//                    }
//                }
//            })
//    }
//
//    // Pictures stuffs
//
//    static func retrieveProfilePictures(completionHandler:@escaping (_ nImgs: Int) -> Void) -> Void {
//        var picIndex = 0
//        // Look after the fb "profile" albumId
//        if let fbProfAlbumId = UserDefaults.standard.value(forKey: "fbProfileAlbumId") {
//            // Do the request into /albumId/photos with fields images
//            FBSDKGraphRequest.init(graphPath: "\(fbProfAlbumId)/photos?fields=images", parameters: [String: String]())
//                .start(completionHandler: {(_, result, error) in
//                    let res =  result as! [String:Any?]
//                    if let dataStruct = res["data"] as? [[String:Any?]] {
//                        for imgStruct in dataStruct {
//                            if let img = imgStruct["images"] as? [[String:Any?]] {
//                                //print(img[0]["source"]!)
//                                UserDefaults.standard.set(img[0]["source"]! as Any, forKey:"fbProfilePicture\(picIndex)")
//                                picIndex += 1
//                                // Only get 4 images
//                                if(picIndex > 4) {
//                                    break
//                                }
//                            }
//                        }
//                    }
//                    completionHandler(picIndex)
//                })
//            return
//        } else {
//            //print("no pic retrieved")
//            completionHandler(0)
//            return
//        }
//    }
}

// Api Graph stuffs
extension FacebookHandler {
    
    static func getMyProfile() -> Future<fbme>{
        struct MyProfileRequest: GraphRequestProtocol {
            struct Response: GraphResponseProtocol {
                var me: fbme?
                init(rawResponse: Any?) {
                    if let dictData = rawResponse as! [String:Any]? {
                        // A small leap to JSON form back to Decodable
                        let jsonData = JSON(dictData)
                        if let string = jsonData.rawString() {
                            if let data = string.data(using: .utf8) {
                                let decoder = JSONDecoder()
                                me = try! decoder.decode(fbme.self, from: data)
                            }
                        }
                    }
                }
            }
            
            var graphPath = "/me"
            var parameters: [String : Any]? = ["fields": "id, email, gender, first_name, birthday, albums{type}, picture.width(800).height(800)"]
            var accessToken = AccessToken.current
            var httpMethod: GraphRequestHTTPMethod = .GET
            var apiVersion: GraphAPIVersion = .defaultVersion
        }
        
        let profilePromise = Promise<fbme>()
        
        let connection = GraphRequestConnection()
        connection.add(MyProfileRequest()) { response, result in
            switch result {
            case .success(let response):
                print("Custom Graph Request Succeeded: \(response)")
                if let me = response.me {
                    profilePromise.fulfill(me)
                } else {
                    let error = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_DECODING_ME, userInfo: ["desc":"could not decode fb profile"])
                    profilePromise.reject(error)
                }
            case .failed(let error):
                let error = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_GRAPH_API, userInfo: ["desc":error.localizedDescription])
                profilePromise.reject(error)
            }
        }
        connection.start()
        
        return profilePromise.future
    }
    
    static func getMyProfilePictures(fromAlbum albumId:String?) -> Future<[URL]> {
        struct MyProfilePictureRequest: GraphRequestProtocol {
            
            var graphPath: String
            var parameters: [String : Any]? = ["fields": "images"]
            var accessToken = AccessToken.current
            var httpMethod: GraphRequestHTTPMethod = .GET
            var apiVersion: GraphAPIVersion = .defaultVersion
            
            struct Response: GraphResponseProtocol {
                var pictureAlbum: PicturesAlbum?
                init(rawResponse: Any?) {
                    if let dictData = rawResponse as! [String:Any]? {
                        // A small leap to JSON form back to Decodable
                        let jsonData = JSON(dictData)
                        if let string = jsonData.rawString() {
                            if let data = string.data(using: .utf8) {
                                let decoder = JSONDecoder()
                                pictureAlbum = try! decoder.decode(PicturesAlbum.self, from: data)
                                if let pA = pictureAlbum {
                                    print(pA)
                                }
                            }
                        }
                    }
                }
            }
            
            init(_ albumId: String) {
                self.graphPath = "/\(albumId)/photos"
            }
            
        }
    
        let profilePromise = Promise<[URL]>()
        
        guard let albId = albumId else {
            let error = NSError(domain: "HoopNetworkApiError", code: FacebookHandler.FB_ERROR_MISSING_ALBUM_ID, userInfo: ["desc":"albumId is missing"])
            profilePromise.reject(error)
            return profilePromise.future
        }
        
        let connection = GraphRequestConnection()
        connection.add(MyProfilePictureRequest(albId)) { response, result in
        switch result {
            case .success(let response):
                print("Custom Graph Request Succeeded: \(response)")
                if let pictureAlbum = response.pictureAlbum {
                    var albumImageUrl = [URL]()
                    for (index,album) in pictureAlbum.data.enumerated() {
                        if let bigImageUrl = album.images.first?.source {
                            albumImageUrl.append(bigImageUrl)
                        }
                        if index == 4 {
                            break
                        }
                    }
                    if let me = AppDelegate.me {
                        me.pictures_urls = albumImageUrl
                    }
                    profilePromise.fulfill(albumImageUrl)
                } else {
                    let error = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_DECODING_ME, userInfo: ["desc":"could not decode fb profile"])
                    profilePromise.reject(error)
                }
            case .failed(let error):
                let error = NSError(domain: "com.ohmyhoop.hoop", code: FB_ERROR_GRAPH_API, userInfo: ["desc":error.localizedDescription])
                profilePromise.reject(error)
            }
        }
        connection.start()
    
        return profilePromise.future
    }
}
    
