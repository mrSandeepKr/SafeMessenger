//
//  SearchUserViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

class SearchUserViewModel {
    public func updateUserList(completion: @escaping ([ChatAppUserModel]) -> Void) {
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
