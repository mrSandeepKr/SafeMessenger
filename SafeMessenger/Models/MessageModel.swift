//
//  MessageModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation
import MessageKit

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
        
        guard let senderObj = sender as? Sender else {
            return [:]
        }
        
        return [
            Constants.sender: senderObj.serialisedObject(),
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
    
    func getSenderInitials() -> String {
        let split: [String] = sender.displayName.split(separator: " ").map{return String($0)}
        guard split.count > 1 else {
            return ""
        }
        let f = String(split[0].first ?? Character("U"))
        let s = String(split[1].first ?? Character("U"))
        return f+s
    }
    
    static func getObject(from dict: [String: Any]) -> Message? {
        guard let senderDict = dict[Constants.sender] as? [String: Any],
              let messageID = dict[Constants.messageID] as? String,
              let sentDateString = dict[Constants.sendDate] as? String,
              let msgType = dict[Constants.msgType] as? String,
              let msgContent = dict[Constants.msgContent] as? String,
              let sentDate = Utils.networkDateFormatter.date(from: sentDateString),
              let msgKind = getMessageKind(from: msgType, content: msgContent),
              let sender = Sender.getObject(from: senderDict),
              let isRead = dict[Constants.isRead] as? Bool
        else {
            return nil
        }
        
        return Message(sender: sender,
                       messageId: messageID,
                       sentDate: sentDate,
                       kind: msgKind,
                       isRead: isRead)
    }
    
    static func getMessageKind(from msgType: String, content: String) -> MessageKind? {
        if msgType == Constants.MessageTypeText {
            return .text(content)
        }
        return nil
    }
}
