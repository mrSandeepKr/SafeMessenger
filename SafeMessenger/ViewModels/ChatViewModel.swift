//
//  ChatViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 06/06/21.
//

import Foundation
import MessageKit

enum FileManagerError: Error {
    case FailedToGetTypeIdentifier
    case FailedToGetFileURL
    case FailedToCopyToTarget
}

class ChatViewModel {
    let memberEmail: String
    var convoId: String?
    let loggedInUserEmail: String
    let loggedInUserImageURLString: String
    var isNewConversation: Bool

    //Get populated on Opening the View
    var memberModel: ChatAppUserModel?
    var selfSender: Sender
    
    var convoMembers: [String] {
        return [loggedInUserEmail, memberEmail]
    }
    
    // Gets populated if the viewModel has a convo Id
    var messages = [Message]()
    
    init(memberEmail: String, convoID: String?) {
        self.memberEmail = memberEmail
        loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
        loggedInUserImageURLString = Utils.shared.getLoggedInUserDisplayURL() ?? ""
        let loggedInUserName = Utils.shared.getLoggedInUserDisplayName() ?? ""
        
        selfSender = Sender(imageURL: loggedInUserImageURLString,
                            senderId: loggedInUserEmail ,
                            displayName: loggedInUserName)
        
        if convoID != nil {
            isNewConversation = false
            convoId = convoID
        }
        else {
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
            DispatchQueue.background(background: {[weak self] in
                if self?.messages.count == 0,
                   let isSenderLoggedIn = self?.messages.last?.isSenderLoggedIn(),
                   isSenderLoggedIn {
                    return
                }
                self?.markLastMsgAsReadIfNeeded()
            })
        }
    }
    
    func removeMessagesObserver() {
        ChatService.shared.removeConversationThreadObserver(for: convoId)
    }
    
    func markLastMsgAsReadIfNeeded() {
        guard let convoId = convoId else {
            return
        }
        ChatService.shared.updateConversationObjectReadStatus(for: loggedInUserEmail,
                                                              convoId: convoId)
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
    
    private func sendMessage(msgKind: MessageKind, completion: @escaping SendMessageCompletion) {
        guard let messageID = createMessageId(), selfSender.displayName != Constants.unknownUser
        else {
            return
        }
        
        let msg = Message(sender: selfSender,
                          messageId: messageID,
                          sentDate: Date(),
                          kind: msgKind)
        if isNewConversation {
            let conversation = ConversationObject(convoID: getConversationId(firstMessageID: messageID),
                                                  lastMessage: msg,
                                                  members: convoMembers)
            let thread = ConversationThread(convoID: conversation.convoID,
                                            messages: [msg])
            print("ChatViewModel: Recieved Request to create conversation")
            DispatchQueue.background(background: {
                ChatService.shared.createNewConversation(with: conversation.members,
                                                         convo: conversation,
                                                         convoThread: thread) {[weak self] res in
                    guard let strongSelf = self else {
                        completion(false,false)
                        return
                    }
                    SearchService.shared.makeBuddy(for: conversation.members, threadId: conversation.convoID) { success in
                        if !success {
                            print("ChatViewModel: Made Buddies Failed")
                        }
                    }
                    DispatchQueue.main.async {
                        switch res {
                        case .success(let res):
                            let isNewConvo = strongSelf.isNewConversation
                            strongSelf.isNewConversation = false
                            strongSelf.convoId = conversation.convoID
                            completion(res, isNewConvo)
                        case .failure(_):
                            completion(false, false)
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
                                               members: self?.convoMembers ?? [],
                                               message: msg) { success in
                    completion(success,false)
                }
            })
        }
    }
    
    func getUrlFromItemProvider(itemProvider: NSItemProvider?,completion:@escaping ResultURLCompletion) {
        guard let itemProvider = itemProvider,
              let typeIdentifier = itemProvider.registeredTypeIdentifiers.first
        else {
            completion(.failure(FileManagerError.FailedToGetTypeIdentifier))
            return
        }
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
            guard error == nil ,let url = url else {
                completion(.failure(FileManagerError.FailedToGetFileURL))
                return
            }

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
            
            do {
                if FileManager.default.fileExists(atPath: targetURL.path) {
                    try FileManager.default.removeItem(at: targetURL)
                }
                try FileManager.default.copyItem(at: url, to: targetURL)
                completion(.success(targetURL))
            }
            catch {
                completion(.failure(FileManagerError.FailedToCopyToTarget))
            }
        }
    }
}

extension ChatViewModel {
    func sendTextMessage(with text:String, completion: @escaping SendMessageCompletion) {
        sendMessage(msgKind: .text(text), completion: completion)
    }
    
    func sendPhotoMessage(with data:Data?, completion: @escaping SendMessageCompletion) {
        guard let messageId = createMessageId(),
              let data = data else {
            completion(false,false)
            return
        }
        let fileName = messageId.replacingOccurrences(of: " ", with: "_") + Constants.pngExtension
        
        StorageManager.shared.uploadImageToMessageSection(to: fileName, imageData: data) {[weak self] res in
            switch res {
            case .success(let url):
                let media = MediaModel(url: url, image: nil)
                self?.sendMessage(msgKind: .photo(media),completion: completion)
                break
            case .failure(_):
                completion(false, false)
                break
            }
        }
    }
    
    func sendVideoMessage(with filepathURL: URL, completion: @escaping SendMessageCompletion) {
        guard let messageId = createMessageId()
        else {
            completion(false,false)
            return
        }
        
        let fileName = messageId.replacingOccurrences(of: " ", with: "_") + Constants.movExtension
        StorageManager.shared.uploadVideoToMessageSection(to: fileName, localFile: filepathURL) {[weak self] res in
            switch res {
            case .success(let url):
                let media = MediaModel(url: url, image: nil)
                print("ChatViewModel: Sending Video Message Success")
                self?.sendMessage(msgKind: .video(media), completion: completion)
                break
            case .failure(_):
                print("ChatViewModel: Couldn't Send Video Message")
                break
            }
        }
    }
}

extension ChatViewModel {
    func deleteConversation() {
        guard let convoId = convoId else {
            return
        }
        
        DispatchQueue.background(background: {[weak self] in
            ChatService.shared.deleteConersation(with: convoId,
                                                 members: self?.convoMembers ?? [],
                                                 completion: {_ in})
            SearchService.shared.removeBuddyRelation(for: self?.convoMembers ?? [],
                                                     completion: {_ in})
        })
    }
}
