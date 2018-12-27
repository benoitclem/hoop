//
//  hoopTests.swift
//  hoopTests
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import XCTest
@testable import hoop

class hoopTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testProfileModel() {
        let json = """
        {
                "id": 58,
                "fb_id": 2037571376502308,
                "nickname": "Flo",
                "firstname": null,
                "lastname": null,
                "sexualorientation_id": 3,
                "gender_id": 1,
                "email": "",
                "description": "pas de description",
                "birthday": "1992-07-19",
                "age_min": 18,
                "age_max": 55,
                "location": null,
                "like_counts": null,
                "friends": null,
                "token_expires_at": null,
                "updated_at": "2018-07-20 00:03:59",
                "created_at": "2018-05-01 10:50:37",
                "timestamp_register": null,
                "timestamp_modify": null,
                "timestamp_lastconnection": "2018-07-20 00:03:59",
                "lovestop_id": null,
                "count_visited_lovestop": null,
                "visited_lovestop": null,
                "count_conversations": null,
                "profile_picture_thumb": "https://rec-pr.vnz.fr/uploads/209_1_1543309086_wLzlp_thumb_blury.jpg",
                "profile_picture": "https://rec-pr.vnz.fr/uploads/e059409a4b489012cf3706f36850ba2a.jpeg",
                "profile_picture2": null,
                "profile_picture3": null,
                "profile_picture4": null,
                "profile_picture5": null,
                "bonus_conversations": 0,
                "superpower": 0,
                "banned": 0,
                "active": 1,
                "sharing_code": "CAF72Q",
                "has_a_godfather": 29,
                "first_message": 1,
                "common_likes": [],
                "age": 26,
                "active_in_hoop": 1
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let p = try! decoder.decode(profile.self, from: data)
        XCTAssertEqual(p.id, 58, "profile.id could not be decoded")
        XCTAssertEqual(p.name, "Flo", "profile.name could not be decoded")
        // Create a date for the purpose to test the internal decoding method
        let dobFormatter = DateFormatter.yyyyMMdd
        let someDobDateTime = dobFormatter.date(from: "1992-07-19")
        XCTAssertEqual(p.dob, someDobDateTime, "date could not be decoded")
        XCTAssertEqual(p.description, "pas de description", "profile.description could not be decoded")
        XCTAssertEqual(p.thumb, URL(string: "https://rec-pr.vnz.fr/uploads/209_1_1543309086_wLzlp_thumb_blury.jpg"),"profile.thumb could not be decoded")
        XCTAssertTrue(p.pictures.count == 1, "p.pictures could not be decoded")
        XCTAssertEqual(p.pictures[0], URL(string: "https://rec-pr.vnz.fr/uploads/e059409a4b489012cf3706f36850ba2a.jpeg"),"profile.picture1 could not be decoded")
        XCTAssertEqual(p.sexualOrientation,3,"profile.sexualOrientation could not be decoded")
        XCTAssertEqual(p.activeInHoop,1,"profile.activeInHoop could not be decoded")
        let lastConnformatter = DateFormatter.yyyyMMddHHmmss
        let somelastConnDateTime = lastConnformatter.date(from: "2018-07-20 00:03:59")
        XCTAssertEqual(p.hoopLastConnection,somelastConnDateTime,"profile.hoopLastConnection could not be decoded")
        XCTAssertEqual(p.commonLikes, [], "profile.commonLikes could not be decoded")
    }
    
    func testHoopModelWoProfiles() {
        let json = """
        {
            "id": 2232,
            "name": "Rue de Vauboyen",
            "category_id": 1,
            "city_id": 29,
            "lat": "48.7600267858208",
            "lon": "2.1968202263652",
            "radius": 1100,
            "periphery": 1300,
            "image": null,
            "permanent": 1,
            "active": 1,
            "permanent_name": null,
            "date_activation": "2018-07-28 10:39:52",
            "date_desactivation": null,
            "updated_at": "2018-07-28 10:39:52",
            "created_at": "2018-07-28 10:39:52"

        }
        """
        
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let h = try! decoder.decode(hoop.self, from: data)
        XCTAssertEqual(h.id, 2232, "hoop.id could not be decoded")
        XCTAssertEqual(h.name, "Rue de Vauboyen", "hoop.name could not be decoded")
        XCTAssertEqual(h.latitude, 48.7600267858208, "hoop.latitude could not be decoded")
        XCTAssertEqual(h.longitude, 2.1968202263652, "hoop.longitude could not be decoded")
        XCTAssertEqual(h.radius, 1100, "hoop.radius could not be decoded")
        XCTAssertEqual(h.periphery, 1300, "hoop.periphery could not be decoded")
        XCTAssertEqual(h.active, 1, "hoop.active could not be decoded")
    }
    
    func testConversationModel() {
        let json = """
        {
            "id": 10,
            "id_exp": 39,
            "id_dest": 28,
            "nickname": "francis",
            "last_message": "salut gros",
            "profile_picture": "https://rec-pr.vnz.fr/uploads/209_1_1543309086_wLzlp_thumb_blury.jpg",
            "timestamp_sent": "1100",
            "timestamp_read": "1300"
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let c = try! decoder.decode(conversation.self, from: data)
        XCTAssertEqual(c.id, 10, "conversation.id could not be decoded")
        XCTAssertEqual(c.expId, 39, "conversation.expId could not be decoded")
        XCTAssertEqual(c.dstId, 28, "conversation.dstId could not be decoded")
        XCTAssertEqual(c.nickname, "francis", "conversation.nickname could not be decoded")
        XCTAssertEqual(c.lastMessage, "salut gros", "conversation.radius could not be decoded")
        XCTAssertEqual(c.timestampSent, "1100", "conversation.periphery could not be decoded")
        XCTAssertEqual(c.timestampRead, "1300", "conversation.active could not be decoded")
    }
    
    func testMessageModel() {
        let json = """
        {
            "id": 10,
            "local_id": 20,
            "id_exp": 30,
            "id_dest": 40,
            "content": "salut gros",
            "timestamp_sent": "1100"
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let m = try! decoder.decode(message.self, from: data)
        XCTAssertEqual(m.id, 10, "message.id could not be decoded")
        XCTAssertEqual(m.locId, 20, "message.locId could not be decoded")
        XCTAssertEqual(m.expId, 30, "message.expId could not be decoded")
        XCTAssertEqual(m.dstId, 40, "message.dstId could not be decoded")
        XCTAssertEqual(m.content, "salut gros", "message.content could not be decoded")
        XCTAssertEqual(m.timestamp, "1100", "message.timestamp could not be decoded")
    }
    
//    func testFbmeFromDictionnary() {
//        let dict = ["id":"10210527622539416","first_name":"Clément","gender":"male"]
//        let decoder = Dictionary()
//    }
    
    func testFbMeFromJson() {
        let json = """
        {
            "id": "10210527622539416",
            "name": "Clément Benoit",
            "first_name": "Clément",
            "gender": "male",
            "email": "benoit.clem@gmail.com",
            "birthday": "02/26/1987",
            "albums": {
                "data": [
                {
                "type": "profile",
                "id": "1477745516219"
                },
                {
                "type": "app",
                "id": "4384223216345"
                },
                {
                "type": "wall",
                "id": "10214095579936121"
                },
                {
                "type": "mobile",
                "id": "1177759136747"
                },
                {
                "type": "app",
                "id": "4674628556297"
                },
                {
                "type": "cover",
                "id": "10200723881372014"
                },
                {
                "type": "normal",
                "id": "3257033357303"
                },
                {
                "type": "normal",
                "id": "4785598010464"
                },
                {
                "type": "normal",
                "id": "4762801680570"
                },
                {
                "type": "normal",
                "id": "2093851118474"
                },
                {
                "type": "normal",
                "id": "1629413147815"
                },
                {
                "type": "normal",
                "id": "1628151516275"
                },
                {
                "type": "normal",
                "id": "1327772766994"
                },
                {
                "type": "normal",
                "id": "1296716030595"
                },
                {
                "type": "normal",
                "id": "1159864249386"
                }
                ],
                "paging": {
                    "cursors": {
                        "before": "MTQ3Nzc0NTUxNjIxOQZDZD",
                        "after": "MTE1OTg2NDI0OTM4NgZDZD"
                    }
                }
            },
            "picture": {
                "data": {
                    "height": 960,
                    "is_silhouette": false,
                    "url": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=10210527622539416&height=800&width=800&ext=1548520710&hash=AeTE07Oyb7_BPSoy",
                    "width": 960
                }
            }
        }
        """
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let _ = try! decoder.decode(fbme.self, from: data)
    }

}
