//
//  ConversationObjectModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation

struct ConversationObject: Serialisable {
    var convoID: String
    var lastMessage: Message
    var members: [String]
    var topic: String = ""
    var convoType: String = "oneToOne"
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.convoID: convoID,
            Constants.lastMessage: lastMessage.serialisedObject(),
            Constants.members: members,
            Constants.topic: topic,
            Constants.convoType: convoType
        ]
    }
    
    func isLastMsgMarkedUnread() -> Bool {
        return !lastMessage.isRead
    }
    
    var recipient: String? {
        guard let loggedInUser = Utils.shared.getLoggedInUserEmail(),
              let recipient = members.first(where: {return $0 != loggedInUser})
        else {
            return nil
        }
        return recipient
    }
}

extension ConversationObject{
    static func getObject(from dict: [String: Any]) -> ConversationObject? {
        guard let lastMessageDict = dict[Constants.lastMessage] as? [String: Any],
              let convoID = dict[Constants.convoID] as? String,
              let members = dict[Constants.members] as? [String],
              let lastMsg = Message.getObject(from: lastMessageDict)
        else {
            return nil
        }
        
        return ConversationObject(convoID: convoID,
                                  lastMessage: lastMsg,
                                  members: members)
    }
}

