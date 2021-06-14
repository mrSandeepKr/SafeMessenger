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
                                completion:@escaping (Result<[ConversationObject], Error>) -> Void) {
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
            print("ChatService: GetAllConversation Success")
            completion(.success(convos))
        }
    }
    
    func createNewConversation(with members: [String],
                               convo: ConversationObject,
                               convoThread: ConversationThread,
                               completion: @escaping (Result<Bool, Error>) -> Void) {
        members.forEach { member in
            addConversation(to: member, convo: convo)
        }
        createConversationThread(for: convoThread,
                                 with: convoThread.messages[0],
                                 completion: completion)
    }
    
    func observeMessagesForConversation(with id: String, completion: @escaping (Result<ConversationThread, Error>) -> Void) {
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
            print("ChatService: get messages for thread Success")
            completion(.success(convoThread))
        }
    }
    
    func sendMessage(to convoId: String, message: Message, completion: @escaping (Bool) -> Void) {
        updateConversationThread(for: convoId, with: message, completion: completion)
    }
}

extension ChatService {
    private func updateConversationThread(for convoId:String,with msg:Message, completion: @escaping (Bool)->Void) {
        let ref = database.child(getMessagesThreadPath(for: convoId)).childByAutoId()
        ref.setValue(msg.serialisedObject()) { err, _ in
            guard err == nil else {
                print("ChatService: Update Conversation Thread Failed")
                completion(false)
                return
            }
            print("ChatService: Update Conversation Thread Success")
            completion(true)
        }
    }
    
    private func updateConversationObject() {
      //todododod
    }
    
    private func addConversation(to email: String,
                                 convo: ConversationObject,
                                 completion: @escaping ((Result<Bool, Error>) -> Void) = {_ in}) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email) else {
            print("ChatService: Add Conversation Object Failed because of empty email")
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
    
    //TODO: make things more decoupled - Only update the thread with latest msgs created here.
    private func createConversationThread(for thread:ConversationThread,
                                          with msg: Message,
                                          completion: @escaping (Result<Bool,Error>) -> Void) {
        let ref = database.child(getMessagesThreadPath(for: thread.convoID)).childByAutoId()
        
        ref.setValue(msg.serialisedObject()) { err, _ in
            guard err == nil else {
                print("ChatService: Update Conversation Thread Failed for msg: \(String(describing:msg))")
                completion(.failure(ChatServiceError.FailedToCreateThread))
                return
            }
            print("ChatService: Update Conversation Thread Success")
            completion(.success(true))
        }
    }
    
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
        print("ChatService: Remove Converation List Observer")
    }
    
    func removeConversationThreadObserver(for id: String?) {
        guard let threadId = id else {
            return
        }
        database.child(threadId).child(Constants.messages).removeAllObservers()
        print("ChatService: Remove Conversation Thread Observer")
    }
}
