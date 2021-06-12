//
//  ChatViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 06/06/21.
//

import Foundation

class ChatViewModel {
    let memberEmail: String
    let memberName: String
    let selfSender: Sender
    let loggedInUserEmail: String
    var isNewConversation: Bool
    var messages = [Message]()
    
    init(memberEmail: String, memberName: String) {
        self.isNewConversation = true
        self.memberEmail = memberEmail
        self.memberName = memberName
        self.loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
        if loggedInUserEmail.isEmpty {
             selfSender = Sender(imageURL: "", senderId: "1", displayName: Constants.unknownUser)
        }
        else {
            selfSender = Sender(imageURL: "", senderId: loggedInUserEmail , displayName: "Random Ran")
        }
    }
}

extension ChatViewModel {
    private func createMessageId() -> String? {
        guard !loggedInUserEmail.isEmpty,
              let loggedInUserSafeEmail = Utils.shared.safeEmail(email: loggedInUserEmail),
              let memberSafeEmail = Utils.shared.safeEmail(email: memberEmail)
        else {
            return nil
        }
        
        let dateString = Utils.networkDateFormatter.string(from: Date())
        let id = "\(loggedInUserSafeEmail)\(memberSafeEmail)\(dateString)"
        return id
    }
    
    private func getConversationId(firstMessageID: String) -> String {
        return "conversation_\(firstMessageID)"
    }
    
    
    func sendMessage(to memberEmail: String, msg: String, completion: @escaping (Bool)-> Void) {
        guard let messageID = createMessageId(), selfSender.displayName != Constants.unknownUser
        else {
            return
        }
        
        if isNewConversation {
            let msg = Message(sender: selfSender,
                            messageId: messageID,
                            sentDate: Date(),
                            kind: .text(msg))
            let conversation = ConversationObject(convoID: getConversationId(firstMessageID: messageID),
                                                  lastMessage: msg,
                                                  members: [loggedInUserEmail, memberEmail])
            let thread = ConversationThread(convoID: conversation.convoID,
                                            messages: [msg])
            print("ChatViewModel: Recieved Request to create conversation")
            DispatchQueue.background(background: {
                ChatService.shared.createNewConversation(with: conversation.members,
                                                         convo: conversation,
                                                         convoThread: thread) { res in
                    DispatchQueue.main.async {
                        switch res {
                        case .success(let res):
                            completion(res)
                        case .failure(_):
                            completion(false)
                        }
                    }
                }
            })
        }
        else {
            //Ping in the existing thread
        }
    }
    
    func createConversation(with memberEmail: String, msg: String, completion: @escaping CreateConversationCompletion) {
        
    }
}
