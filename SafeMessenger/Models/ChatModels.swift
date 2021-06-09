//
//  ChatViewModels.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 02/06/21.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var content: String
    var is_read: Bool = false
}

struct Sender: SenderType {
    var imageURL: String
    var senderId: String
    var displayName: String
}

struct ConversationObject {
    var id: String
    var lastMessage: Message
    var memberEmail: [String]
    var topic: String = ""
    var convoType: String = "oneToOne"
}

struct ConversationThread {
    var messages: [Message]
}
