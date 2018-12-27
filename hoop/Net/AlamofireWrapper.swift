//
//  AlamofireWrapper.swift
//  hoop
//
//  Created by Clément on 21/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireWrapper {
    
    var baseUrl: String?

    init(with plistKey:String){
        // Look into plist for the configuration
        let netApiConfig = Bundle.main.object(forInfoDictionaryKey: plistKey)
        assert(netApiConfig != nil)
        let configArray = netApiConfig as! [String:String]
        self.baseUrl = configArray["baseUrl"]
    }
    
    func urlEncode(_ argumentsDictionnary:  [String:String]) -> String {
        var first = true
        var args:String = ""
        for key in argumentsDictionnary.keys {
            if(!first) {
                args += "&"
            }  else {
                first = false
            }
            args += key + "=" + argumentsDictionnary[key]!
        }
        return args
    }
    
    
}
