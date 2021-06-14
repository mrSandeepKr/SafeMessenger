//
//  ChatListViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 01/06/21.
//

import Foundation

class ChatListViewModel {
    var fetchedChats: Array<ConversationObject> = []
    
    init() {
        
    }
    
    func startListeningForChats(completion:@escaping (Bool)->Void) {
        DispatchQueue.background( background: {[weak self] in
            self?.fetchData(completion: {[weak self] success in
                guard let strongSelf = self else {
                    completion(false)
                    return
                }
                completion(success && (strongSelf.fetchedChats.count > 0))
            })
        })
    }
    
    private func fetchData(completion:@escaping (Bool)->Void) {
        guard let loggedInUser = Utils.shared.getLoggedInUserEmail(), !loggedInUser.isEmpty
        else {
            completion(false)
            return
        }
        
        ChatService.shared.observeAllConversation(with: loggedInUser) {[weak self] res in
            switch res {
            case .success(let convos):
                self?.fetchedChats = convos
                completion(true)
                break
            default:
                completion(false)
            }
        }
    }
    
    func removeListerForConvo() {
        ChatService.shared.removeConversationListObserver()
    }
}
