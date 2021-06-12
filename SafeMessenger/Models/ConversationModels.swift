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
            Constants.displatName: displayName
        ]
    }
}

extension SenderType {
    func serialisedObject() -> [String : Any] {
        return [
            Constants.senderID: senderId,
            Constants.displatName: displayName
        ]
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
