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
        var msgs = [MessageDict]()
        messages.forEach { msg in
            msgs.append(msg.serialisedObject())
        }
        return [
            Constants.messages: msgs
        ]
    }
    
    static func getObject(for id: String, dictArray: [MessageDict]) -> ConversationThread {
        let messages: [Message] = dictArray.compactMap { dict in
            guard let messsage = Message.getObject(from: dict)
            else {
                return nil
            }
            return messsage
        }
        
        return ConversationThread(convoID: id,
                                  messages: messages)
    }
}
