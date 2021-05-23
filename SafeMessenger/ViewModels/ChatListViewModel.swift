//
//  ChatListViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation

class ChatListViewModel {
    public var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
}
