//
//  ConversationThreadModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation

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
