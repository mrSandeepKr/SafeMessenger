//
//  ChatListTableViewCellViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 12/06/21.
//

import Foundation
import UIKit

class ChatListTableViewCellViewModel {
    private let convo: ConversationObject
    
    init(convo: ConversationObject) {
        self.convo = convo
    }
    
    func getLastMsgDateString() -> String {
        let date = convo.lastMessage.sentDate
        let start = Calendar.current.startOfDay(for: Date())
        if date >= start {
            return Utils.hrMinDateFormatter.string(from: date)
        }
        return "YesterDay"
    }
    
    func getChatTitle() -> String {
        guard !convo.topic.isEmpty else {
            guard let loggedInUser = Utils.shared.getLoggedInUserEmail() else {
                return ""
            }
            let members = convo.members.filter{ $0 != loggedInUser}
            return members.joined(separator: ", ")
        }
        return convo.topic
    }
    
    func getLastMessageText() -> String {
        let msg = convo.lastMessage
        guard let msgPreview =  msg.getMessagePreviewText()
        else {
            return ""
        }
        return msgPreview
    }
}
