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
}

struct Sender: SenderType {
    var imageURL: String
    var senderId: String
    var displayName: String
}
