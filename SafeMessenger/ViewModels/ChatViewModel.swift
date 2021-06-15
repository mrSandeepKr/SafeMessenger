//
//  ChatViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 06/06/21.
//

import Foundation

class ChatViewModel {
    let memberEmail: String
    var convoId: String?
    let loggedInUserEmail: String
    let loggedInUserImageURLString: String
    var isNewConversation: Bool
    let isLastMsgMarkedUnRead: Bool
    
    //Get populated on Opening the View
    var memberModel: ChatAppUserModel?
    var selfSender: Sender
    
    // Gets populated if the viewModel has a convo Id
    var messages = [Message]()
    
    init(memberEmail: String, convo: ConversationObject?) {
        self.memberEmail = memberEmail
        loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
        loggedInUserImageURLString = Utils.shared.getLoggedInUserDisplayURL() ?? ""
        let loggedInUserName = Utils.shared.getLoggedInUserDisplayName() ?? ""
        
        selfSender = Sender(imageURL: loggedInUserImageURLString,
                            senderId: loggedInUserEmail ,
                            displayName: loggedInUserName)
        
        if convo != nil {
            isNewConversation = false
            isLastMsgMarkedUnRead = convo!.isLastMsgMarkedUnread()
            convoId = convo!.convoID
        }
        else {
            isLastMsgMarkedUnRead = false
            isNewConversation = true
        }
    }
}

extension ChatViewModel {
    func getUserInfoForChat(completion: @escaping (Bool)->Void) {
        ApiHandler.shared.fetchUserInfo(for: memberEmail) {[weak self] res in
            switch res {
            case .success(let model):
                self?.memberModel = model
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    ///Adds the Observer on Messages for the Chat Open
    func getMessages(completion: @escaping (Bool)->Void) {
        guard let id = convoId else {
            completion(false)
            return
        }
        print("ChatViewModel: Adding Observer On Messages For Thread")
        ChatService.shared.observeMessagesForConversation(with: id) {[weak self] res in
            switch res {
            case .success(let thread):
                self?.messages = thread.messages
                completion(true)
                break
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func removeMessagesObserver() {
        ChatService.shared.removeConversationThreadObserver(for: convoId)
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
        
        let msg = Message(sender: selfSender,
                        messageId: messageID,
                        sentDate: Date(),
                        kind: .text(msg))
        let members = [loggedInUserEmail, memberEmail]
        if isNewConversation {
            let conversation = ConversationObject(convoID: getConversationId(firstMessageID: messageID),
                                                  lastMessage: msg,
                                                  members: members)
            let thread = ConversationThread(convoID: conversation.convoID,
                                            messages: [msg])
            print("ChatViewModel: Recieved Request to create conversation")
            DispatchQueue.background(background: {
                ChatService.shared.createNewConversation(with: conversation.members,
                                                         convo: conversation,
                                                         convoThread: thread) {[weak self] res in
                    DispatchQueue.main.async {
                        switch res {
                        case .success(let res):
                            self?.isNewConversation = false
                            self?.convoId = conversation.convoID
                            completion(res)
                        case .failure(_):
                            completion(false)
                        }
                    }
                }
            })
        }
        else {
            DispatchQueue.background(background: {[weak self] in
                guard let convoId = self?.convoId else {
                    return
                }
                ChatService.shared.sendMessage(to: convoId,
                                               members: members,
                                               message: msg,
                                               completion: completion)
            })
        }
    }
    
    func markLastMsgAsReadIfNeeded() {
        guard isLastMsgMarkedUnRead, let convoId = convoId else {
            return
        }
        ChatService.shared.updateConversationObjectReadStatus(for: loggedInUserEmail,
                                                              convoId: convoId)
    }
}
