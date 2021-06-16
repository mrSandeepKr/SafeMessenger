//
//  SearchUserViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

class SearchUserViewModel {
    private var usersSet = [SearchUserModel]()
    var results = [SearchUserModel]()
    private var areResultsFetched = false
    private let loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
    
    init() {
        updateUserList {[weak self] users in
            self?.usersSet = users
            self?.areResultsFetched = true
        }
    }
    
    func updateUserList(completion: @escaping ([SearchUserModel]) -> Void) {
        ApiHandler.shared.fetchAllUsers { res in
            switch res {
            case .success(let users):
                completion(users)
            default:
                break
            }
        }
    }
    
    func searchUsers(query: String) {
        guard areResultsFetched else {
            return
        }
        
        results = usersSet.filter { user in
            let email = user.email.lowercased()
            let fn = user.firstName
            let sn = user.secondName
            
            return (fn.hasPrefix(query) || sn.hasPrefix(query) || email.hasPrefix(query))
                && (email != loggedInUserEmail.lowercased())
        }
    }

    var hasAnyResultToShow: Bool {
        return areResultsFetched
    }
}
