//
//  ChatListViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 01/06/21.
//

import Foundation

class ChatListViewModel {
    var fetchedChats: Array<Any> = []
    
    init() {
        
    }
    
    func fetchData(completion: (Bool)->Void) {
        fetchedChats = ["data"]
        completion(true)
    }
}
