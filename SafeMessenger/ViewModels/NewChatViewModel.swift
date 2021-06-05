//
//  NewChatViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

class NewChatViewModel {
    public func updateUserList(completion: @escaping (UsersList) -> Void) {
        ApiHandler.shared.fetchAllUsers { res in
            switch res {
            case .success(let users):
                completion(users)
            default:
                break
            }
        }
    }
}
