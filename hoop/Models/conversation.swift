//
//  conversation.swift
//  hoop
//
//  Created by Clément on 14/12/2018.
//  Copyright © 2018 hoop. All rights reserved.
//

import UIKit

class conversation: Decodable, Encodable {
    
    var id: Int?
    var expId: Int?
    var dstId: Int?
    var nickname: String?
    var lastMessage: String?
    var profilePictureUrl: URL?
    var dateSent: Date? // This should not be replace by dates?
    var dateRead: Date? // This should not be replace by dates?
    
    init() {
        
    }
    
    var when: String {
        get {
            if let date = dateSent {
                let dateFormatter: DateFormatter!
                if NSCalendar.current.compare(date, to: Date.init(), toGranularity: .day) == ComparisonResult.orderedSame {
                    dateFormatter = DateFormatter.HHmm
                } else {
                    dateFormatter = DateFormatter.ddMMyy
                }
                return dateFormatter.string(from: date)
            } else {
                return ""
            }
        }
    }
    
    var finalExpId: Int {
        get {
            var _finalExpId = expId!
            if expId == AppDelegate.me?.id {
                _finalExpId = dstId!
            }
            return _finalExpId
        }
    }
    
    
    enum CodingKeys : String, CodingKey {
        case id
        case expId = "id_exp"
        case dstId = "id_dest"
        case nickname
        case lastMessage = "last_message"
        case profilePictureUrl = "profile_picture"
        case dateSentStr = "timestamp_sent"
        case dateReadStr = "timestamp_read"
        case dateSent
        case dateRead
    }
    
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decode(Int.self, forKey: .id)
        nickname = try? container.decode(String.self, forKey: .nickname)
        expId = try? container.decode(Int.self, forKey: .expId)
        dstId = try? container.decode(Int.self, forKey: .dstId)
        lastMessage = try? container.decode(String.self, forKey: .lastMessage)
        profilePictureUrl  = try? container.decode(URL.self, forKey: .profilePictureUrl)
        if container.contains(.dateSent) {
            dateSent = try? container.decode(Date.self, forKey: .dateSent)
        } else if container.contains(.dateSentStr){
            if let dateSentString = try? container.decode(String.self, forKey: .dateSentStr) {
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
        if container.contains(.dateRead) {
            dateRead = try? container.decode(Date.self, forKey: .dateRead)
        } else if container.contains(.dateReadStr){
            if let dateReadString = try? container.decode(String.self, forKey: .dateReadStr) {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(expId, forKey: .expId)
        try container.encode(dstId, forKey: .dstId)
        try container.encode(lastMessage, forKey: .lastMessage)
        try container.encode(profilePictureUrl, forKey: .profilePictureUrl)
        try container.encode(dateSent, forKey: .dateSent)
        try container.encode(dateRead, forKey: .dateRead)
    }
    
    func update(with conversation:conversation) -> Bool{
        var modified = false
        if expId != conversation.expId {
            expId = conversation.expId
            modified = true
        }
        if dstId != conversation.dstId {
            dstId = conversation.dstId
            modified = true
        }
        if lastMessage != conversation.lastMessage {
            lastMessage = conversation.lastMessage
            modified = true
        }
        if dateSent != conversation.dateSent {
            dateSent = conversation.dateSent
            modified = true
        }
        if dateRead != conversation.dateRead {
            dateRead = conversation.dateRead
            modified = true
        }
        if profilePictureUrl != conversation.profilePictureUrl {
            profilePictureUrl = conversation.profilePictureUrl
            modified = true
        }
        return modified
    }
    
    static func createUserThConversation() -> conversation {
        let UTHConv = conversation()
        UTHConv.id = 0
        UTHConv.dstId = AppDelegate.me?.id!
        UTHConv.expId = 1
        UTHConv.nickname = "Team Hoop"
        UTHConv.dateRead = Date()
        UTHConv.dateSent = Date()
        UTHConv.lastMessage = "Communique avec la team"
        return UTHConv
    }
    
}

class conversations: Codable {
    var chat_data: [conversation]?
    var th_data: [conversation]?
}


class conversationManager: Codable {
    
    var th_conversations = [conversation]()
    var user_th_conversation: conversation = conversation.createUserThConversation()
    var conversations = [conversation]()

    func save() {
        let defaults = Defaults()
        defaults.set(self, for: .conversations)
    }
    
    static func get() -> conversationManager? {
        let defaults = Defaults()
        return defaults.get(for: .conversations)
    }
    
    func update(withConversations convs: conversations) -> Bool {
        var modified = false
        var mutableConversations = conversations
        if let userChats = convs.chat_data {
            for userChat in userChats {
                // Treat the TH id differently
                if userChat.dstId == 1 || userChat.expId == 1  {
                    let localModified = user_th_conversation.update(with: userChat)
                    if !modified && localModified {
                        modified = true
                    }
                } else {
                    if let conv = mutableConversations.first(where: {$0.finalExpId == userChat.finalExpId}) {
                        let localModified = conv.update(with: userChat)
                        if !modified && localModified {
                            modified = true
                        }
                    } else {
                        mutableConversations.append(userChat)
                        modified = true
                    }
                }
            }
            // Apply sorting
            mutableConversations.sort(by: { conv1, conv2 in return conv1.dateSent! > conv2.dateSent!})
            // Apply mods all in once
            conversations = mutableConversations
        }
        return modified
    }
}


