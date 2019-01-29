//
//  message.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class message: Codable {
    var id: Int?
    var locId: UInt64?
    var expId: Int?
    var dstId: Int?
    var content: String?
    var dateSent: Date?
    var dateRead: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case locId = "local_id"
        case expId = "id_exp"
        case dstId = "id_dest"
        case content
        case dateSent = "timestamp_sent"
        case dateRead = "timestamp_read"
    }
    
    init(with message:String,and destIdent:Int) {
        content = message
        dstId = destIdent
        locId = UInt64.random64()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        locId = try container.decode(UInt64.self, forKey: .locId)
        expId = try container.decode(Int.self, forKey: .expId)
        dstId = try container.decode(Int.self, forKey: .dstId)
        content = try container.decode(String.self, forKey: .content)
        if container.contains(.dateSent){
            if let dateSentString = try? container.decode(String.self, forKey: .dateSent) {
                let lcformatter = DateFormatter.yyyyMMddHHmmss
                if let date = lcformatter.date(from: dateSentString) {
                    dateSent = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .dateSent,
                                                           in: container,
                                                           debugDescription: "Date string does not match format expected by formatter.")
                }
            }
        }
        if container.contains(.dateRead){
            if let dateReadString = try? container.decode(String.self, forKey: .dateSent) {
                let lcformatter = DateFormatter.yyyyMMddHHmmss
                if let date = lcformatter.date(from: dateReadString) {
                    dateRead = date
                } else {
                    throw DecodingError.dataCorruptedError(forKey: .dateRead,
                                                           in: container,
                                                           debugDescription: "Date string does not match format expected by formatter.")
                }
            }
        }
    }
}

class messageManager: Codable {
    
    var keyString: Key<messageManager>!
    var messages = [message]()
    
    init() {
        
    }
    
    enum CodingKeys: String, CodingKey {
        case messages
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decode([message].self, forKey: .messages)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messages, forKey: .messages)
    }
    
    func save() {
        let defaults = Defaults()
        defaults.set(self, for: self.keyString)
    }
    
    static func get(withKey keyString:String) -> messageManager? {
        let defaults = Defaults()
        let k = Key<messageManager>(keyString)
        let messageManager = defaults.get(for: k)
        messageManager?.keyString = k
        return messageManager
    }
    
    func update(with msgs:[message]) -> (toUpdate:[IndexPath],toInsert:[IndexPath]) {
        
        var toUpdate = [IndexPath]()
        var toInsert = [IndexPath]()
        var nNewMsg = 0
        
        for msg in msgs {
            if let index = messages.index(where: { m in
                if m.id == 0 {
                    // mean new message
                    return m.locId == msg.locId
                } else {
                    return m.id == msg.id
                }
            }) {
                // Update specific row
                let existingMessage = messages[index]
                //print("updating",existingMessage)
                existingMessage.dateSent = msg.dateSent
                // When you try to update a newly inserted row (can happen when ios think message is not gone and user resend it with same locId)
                toUpdate.append(IndexPath(item: messages.count-1-index, section: 0))
            } else {
                nNewMsg += 1
                messages.append(msg)
            }
            
            if nNewMsg != 0 {
                for i in 0...nNewMsg-1 {
                    toInsert.append(IndexPath(item: i, section: 0))
                }
            }
        }
        
        return (toUpdate, toInsert)
    }
}
