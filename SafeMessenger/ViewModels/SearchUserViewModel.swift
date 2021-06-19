//
//  SearchUserViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

class SearchUserViewModel {
    private var usersSet = [ChatAppUserModel]()
    var results = [ChatAppUserModel]()
    var buddyList = [BuddyUserModel]()
    private var areResultsFetched = false
    private let loggedInUserEmail = Utils.shared.getLoggedInUserEmail() ?? ""
    
    init() {
        updateUserLists {_ in}
    }
    
    private func updateUserLists(completion: @escaping SuccessCompletion) {
        DispatchQueue.background(background: {[weak self] in
            guard let strongSelf = self else {
                return
            }
            SearchService.shared.fetchAllUsers {[weak strongSelf] res in
                switch res {
                case .success(let users):
                    strongSelf?.usersSet = users
                    strongSelf?.areResultsFetched = true
                default:
                    break
                }
            }
            SearchService.shared.fetchBuddyListOfUsers(with: strongSelf.loggedInUserEmail) {[weak strongSelf] res in
                switch res{
                case .success(let buddies):
                    strongSelf?.buddyList = buddies
                    break
                default:
                    break
                }
            }
        })
    }
    
    func searchUsers(query: String) {
        guard areResultsFetched else {
            return
        }
        
        results = usersSet.filter { user in
            let email = user.email.lowercased()
            let fn = user.firstName.lowercased()
            let sn = user.secondName.lowercased()
            
            return (fn.hasPrefix(query) || sn.hasPrefix(query) || email.hasPrefix(query))
                && (email != loggedInUserEmail.lowercased())
        }
    }
    
    func getConvoIdForUser(with email: String) -> String? {
        return buddyList.first{return $0.email == email}?.convoId
    }

    var hasAnyResultToShow: Bool {
        return areResultsFetched
    }
}
