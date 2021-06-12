//
//  ChatViewModels.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 02/06/21.
//

import Foundation
import MessageKit

// Doing this over Encodable as wanted something custom that doesn't throw randomly
protocol Serialisable {
    func serialisedObject() -> [String: Any]
}

struct Sender: SenderType, Serialisable {
    var imageURL: String
    var senderId: String
    var displayName: String
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.imageURL: imageURL,
            Constants.senderID: senderId,
            Constants.displayName: displayName
        ]
    }
    
    static func getObject(from dict: [String: Any]) -> Sender? {
        guard let imageURL = dict[Constants.imageURL] as? String,
              let displayName = dict[Constants.displayName] as? String,
              let senderID = dict[Constants.senderID] as? String
        else {
            return nil
        }
        return Sender(imageURL: imageURL,
                      senderId: senderID,
                      displayName: displayName)
    }
}

extension SenderType {
    func serialisedObject() -> [String : Any] {
        return [
            Constants.imageURL: Utils.shared.getStorageUrlForEmail(for: senderId),
            Constants.senderID: senderId,
            Constants.displayName: displayName
        ]
    }
    
    func getSenderFirstName() -> String? {
        let split = displayName.split(separator: " ").map { return String($0)}
        guard split.count > 0 else {
            return nil
        }
        return split[0]
    }
}

struct Message: MessageType, Serialisable {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var isRead: Bool = false
    
    func serialisedObject() -> [String : Any] {
        var message = ""
        var type = ""
        switch kind {
        case .text(let msg):
            message = msg
            type = Constants.MessageTypeText
        default:
            break
        }
        
        return [
            Constants.sender: sender.serialisedObject(),
            Constants.messageID: messageId,
            Constants.sendDate: Utils.networkDateFormatter.string(from: sentDate),
            Constants.isRead: isRead,
            Constants.msgContent: message,
            Constants.msgType: type
        ]
    }
    
    func getMessagePreviewText() -> String? {
        switch kind {
        case .text(let msg):
            return msg
        default:
            return nil
        }
    }
    
    func isSenderLoggedIn() -> Bool {
        guard let loggedInUserEmail = Utils.shared.getLoggedInUserEmail()
        else {
            return false
        }
        return loggedInUserEmail == sender.senderId
    }
    
    static func getObject(from dict: [String: Any]) -> Message? {
        guard let senderDict = dict[Constants.sender] as? [String: Any],
              let messageID = dict[Constants.messageID] as? String,
              let sentDateString = dict[Constants.sendDate] as? String,
              let msgType = dict[Constants.msgType] as? String,
              let msgContent = dict[Constants.msgContent] as? String,
              let sentDate = Utils.networkDateFormatter.date(from: sentDateString),
              let msgKind = getMessageKind(from: msgType, content: msgContent),
              let sender = Sender.getObject(from: senderDict)
        else {
            return nil
        }
        
        return Message(sender: sender,
                       messageId: messageID,
                       sentDate: sentDate,
                       kind: msgKind)
    }
    
    static func getMessageKind(from msgType: String, content: String) -> MessageKind? {
        if msgType == Constants.MessageTypeText {
            return .text(content)
        }
        return nil
    }
}

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
    
    static func getObject(from dict: [String: Any]) -> ConversationObject? {
        guard let lastMessageDict = dict[Constants.lastMessage] as? [String: Any],
              let convoID = dict[Constants.convoID] as? String,
              let members = dict[Constants.members] as? [String],
//              let _ = dict[Constants.topic] as? String,
//              let _ = dict[Constants.convoType] as? String,
              let lastMsg = Message.getObject(from: lastMessageDict)
        else {
            return nil
        }
        
        return ConversationObject(convoID: convoID,
                                  lastMessage: lastMsg,
                                  members: members)
    }
}

struct ConversationThread: Serialisable {
    var convoID: String
    var messages: [Message]
    
    func serialisedObject() -> [String : Any] {
        var msgs = [[:]]
        messages.forEach { msg in
            msgs.append(msg.serialisedObject())
        }
        return [
            Constants.messages: msgs
        ]
    }
}
