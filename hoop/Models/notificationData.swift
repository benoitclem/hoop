//
//  notificationData.swift
//  hoop
//
//  Created by Clément on 29/01/2019.
//  Copyright © 2019 hoop. All rights reserved.
//

import Foundation

class notificationData {
    var title: String?
    var body: String?
    var badge: Int?
    var sound: String?
    var clientId : Int?
    var atturl: URL?
    var thData: Int?
    var destName: String?
    
    init(with userInfo: [AnyHashable : Any]) {
        let aps = userInfo[AnyHashable("aps")] as! [String:Any]
        let alert = aps["alert"] as! [String:Any]
        body = alert["body"] as! String?
        title = alert["title"] as! String?
        badge = aps["badge"] as! Int?
        print(userInfo)
        clientId = userInfo[AnyHashable("client-id")] as! Int?
        if let strURL = userInfo[AnyHashable("attachment-url")] as! String? {
            atturl = URL(string: strURL)
        }
        thData = userInfo[AnyHashable("th-data")] as! Int?
        destName = userInfo[AnyHashable("client-name")] as! String?
        print(body)
        print(title)
        print(badge)
        print(clientId)
        print(atturl)
        print(thData)
        print(destName)
    }
}
