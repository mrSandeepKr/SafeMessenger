//
//  ConversationThreadModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation
import Firebase

struct ConversationThread: Serialisable {
    var convoID: String
    var messages: [Message]
    
    func serialisedObject() -> [String : Any] {
        var msgs = [MessageDict]()
        messages.forEach { msg in
            msgs.append(msg.serialisedObject())
        }
        return [
            Constants.messages: msgs
        ]
    }
    
    static func getObject(for id: String, snap: DataSnapshot) -> ConversationThread {
        var messages = [Message]()
        for child in snap.children.allObjects {
            guard let base = child as? DataSnapshot,
                  let msgDict = base.value as? MessageDict,
                  let msg = Message.getObject(from: msgDict)
            else {
                continue
            }
            messages.append(msg)
        }
        
        return ConversationThread(convoID: id,
                                  messages: messages)
    }
}
