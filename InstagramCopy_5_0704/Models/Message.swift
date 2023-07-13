//
//  Message.swift
//  InstagramCopy_5_0704
//
//  Created by 계은성 on 2023/07/13.
//

import Foundation
import Firebase

final class Message {
    var messageText: String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    func getChatPartnerId() -> String {
        guard let currentUid = Auth.auth().currentUser?.uid else { return "" }
        
        if fromId == currentUid {
            return toId
        } else {
            return fromId
        }
        
    }
}
