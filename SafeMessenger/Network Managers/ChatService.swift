//
//  ChatService.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 09/06/21.
//

import Foundation
import FirebaseDatabase

enum ChatServiceError: Error {
    case FailedToCreateThread
    case FailedToFetchAllConvoObjects
    case FailedToGetUser
    case FailedToGetThread
}

final class ChatService {
    static let shared = ChatService()
    
    private let database = Database.database(url: URLStrings.databaseURL).reference()
}

extension ChatService {
    func observeAllConversation(with member: String,
                                completion:@escaping FetchAllConversationsCompletion) {
        guard let member = Utils.shared.safeEmail(email: member) else {
            completion(.failure(ChatServiceError.FailedToFetchAllConvoObjects))
            return
        }
        
        let ref = database.child("\(member)/\(Constants.conversations)")
        ref.observe(.value) { snapshot in
            var convos = [ConversationObject]()
            
            for child in snapshot.children.allObjects {
                guard let base = child as? DataSnapshot,
                      let convoDict = base.value as? [String: Any],
                      let convo = ConversationObject.getObject(from: convoDict)
                else {
                    continue
                }
                convos.append(convo)
            }
            
            if convos.count != snapshot.childrenCount {
                print("ChatService: Some Objects couldn't be parsed while fetching")
            }
            print("ChatService: Get all conversation Success")
            completion(.success(convos))
        }
    }
    
    func createNewConversation(with members: [String],
                               convo: ConversationObject,
                               convoThread: ConversationThread,
                               completion: @escaping ResultBoolCompletion) {
        guard let loggedInUserEmail = Utils.shared.getLoggedInUserEmail() else {
            completion(.failure(ChatServiceError.FailedToGetUser))
            return
        }
        
        members.forEach { member in
            var convo = convo
            convo.lastMessage.isRead = (member == loggedInUserEmail)
            addConversation(to: member, convo: convo)
        }
        createOrUpdateConversationThread(for: convoThread.convoID,
                                         with: convoThread.messages[0],
                                         completion: completion)
    }
    
    func observeMessagesForConversation(with id: String, completion: @escaping FetchConversationThreadCompletion) {
        database.child(id).child(Constants.messages).observe(.value) { snapshot in
            guard snapshot.hasChildren()
            else {
                print("ChatService: get messages for thread Failed")
                completion(.failure(ChatServiceError.FailedToGetThread))
                return
            }
            
            let convoThread = ConversationThread.getObject(for: id, snap: snapshot)
            if convoThread.messages.count != snapshot.childrenCount {
                print("ChatService: Could resolve few messages for Thread :\(id)")
            }
            print("ChatService: Get messages for thread Success")
            completion(.success(convoThread))
        }
    }
    
    func sendMessage(to convoId: String,
                     members: [String],
                     message: Message,
                     completion: @escaping (Bool) -> Void) {
        guard let loggedInUserEmail = Utils.shared.getLoggedInUserEmail() else {
            completion(false)
            return
        }
        members.forEach { member in
            var mes = message
            mes.isRead = (member == loggedInUserEmail)
            updateConversationObjectLastMessage(for: member,
                                                convoId: convoId,
                                                with: mes,
                                                completion: {_ in})
        }
        createOrUpdateConversationThread(for: convoId, with: message) { res in
            switch res {
            case .success(let success):
                completion(success)
            case .failure(_):
                completion(false)
            }
        }
    }
}

extension ChatService {
    /// Updates the Conversation Objects for user passed in - Last Message
    private func updateConversationObjectLastMessage(for email: String,
                                                     convoId: String,
                                                     with msg: Message,
                                                     completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email) else {
            print("ChatService: Update Last Message for Conversation Object Failed")
            completion(false)
            return
        }
        let ref = database.child(getConversationOjectPath(safeEmail: email))
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let base = child as? DataSnapshot,
                      let dict = base.value as? [String: Any],
                      let convo = ConversationObject.getObject(from: dict),
                      convo.convoID == convoId
                else {
                    continue
                }
                print("ChatService: Update Last Message for Conversation Object Success")
                let key = base.key
                ref.child(key).updateChildValues([Constants.lastMessage: msg.serialisedObject()])
                completion(true)
                return
            }
        }
        completion(false)
    }
    
    /// Updates the read status of the last Msg in the conversationObject for the user passed in
    func updateConversationObjectReadStatus(for email: String,
                                            convoId: String,
                                            completion: @escaping ResultBoolCompletion = {_ in}) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email) else {
            print("ChatService: Update isRead for Conversation Object Failed")
            return
        }
        let ref = database.child(getConversationOjectPath(safeEmail: email))
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let base = child as? DataSnapshot,
                      let dict = base.value as? [String: Any],
                      let convo = ConversationObject.getObject(from: dict),
                      convo.convoID == convoId
                else {
                    continue
                }
                print("ChatService: Update isRead for Conversation Object Success")
                let key = base.key
                ref.child(key).child(Constants.lastMessage).updateChildValues([Constants.isRead: true])
                break
            }
        }
    }
    
    /// Adds Conversation to the Conversation Object List of the user passed.
    private func addConversation(to email: String,
                                 convo: ConversationObject,
                                 completion: @escaping ResultBoolCompletion = {_ in}) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email) else {
            print("ChatService: Add Conversation Object Failed - because of empty email")
            return
        }
        let ref = database.child(getConversationOjectPath(safeEmail: email)).childByAutoId()
        ref.setValue(convo.serialisedObject()) { err, _ in
            guard err == nil else {
                completion(.failure(err!))
                return
            }
            print("ChatService: Add Conversation Object Success")
            completion(.success(true))
        }
    }
    
    ///This function does one of the below two:
    /// 1. Create Conversation Thread if not created and add Message to it.
    /// 2. If Conversation Thread is already created add Message to it.
    private func createOrUpdateConversationThread(for convoID:String,
                                                  with msg: Message,
                                                  completion: @escaping ResultBoolCompletion) {
        let ref = database.child(getMessagesThreadPath(for: convoID)).childByAutoId()
        
        ref.setValue(msg.serialisedObject()) { err, _ in
            guard err == nil else {
                print("ChatService: Update Conversation Thread Failed for msg: \(String(describing:err))")
                completion(.failure(ChatServiceError.FailedToCreateThread))
                return
            }
            print("ChatService: Update Conversation Thread Success")
            completion(.success(true))
        }
    }
}

extension ChatService {
    func getMessagesThreadPath(for convoId: String) -> String {
        return "\(convoId)/\(Constants.messages)"
    }
    
    func getConversationOjectPath(safeEmail: String) -> String {
        return "\(safeEmail)/\(Constants.conversations)"
    }
}

extension ChatService {
    func removeConversationListObserver() {
        guard let safeEmail = Utils.shared.getLoggedInUserSafeEmail() else {
            return
        }
        database.child("\(safeEmail)/\(Constants.conversations)").removeAllObservers()
        //print("ChatService: Remove Converation List Observer")
    }
    
    func removeConversationThreadObserver(for id: String?) {
        guard let threadId = id else {
            return
        }
        database.child(threadId).child(Constants.messages).removeAllObservers()
        //print("ChatService: Remove Conversation Thread Observer")
    }
}
