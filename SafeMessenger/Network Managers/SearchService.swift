//
//  SearchService.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 17/06/21.
//

import Foundation
import FirebaseDatabase

enum SearchServiceError: Error {
    case FailedToFetchAllUsers
}

class SearchService {
    static let shared = SearchService()
    private let database = Database.database(url: URLStrings.databaseURL).reference()
    
    func fetchAllUsers(completion: @escaping FetchSearchUsersCompletion) {
        let ref = database.child(Constants.users)
        ref.observeSingleEvent(of: .value) { snapshot in
            var userObjects = [SearchUserModel]()
            for child in snapshot.children {
                guard let base = child as? DataSnapshot,
                      let value = base.value as? UserDict,
                      let user = SearchUserModel.getObject(from: value)
                else {
                    print("SearchService: Fetch All users Failed")
                    completion(.failure(SearchServiceError.FailedToFetchAllUsers))
                    return
                }
                userObjects.append(user)
            }
            print("SearchService: Fetch All users Success")
            completion(.success(userObjects))
        }
    }
    
    func fetchBuddyListOfUsers(with email: String, completion:@escaping FetchBuddyListCompletion) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email)
        else {
            return completion(.failure(SearchServiceError.FailedToFetchAllUsers))
        }
        
        let ref = database.child(getBuddlyListPath(safeEmail: email))
        ref.observeSingleEvent(of: .value) { snapshot in
            var buddies = [BuddyUserModel]()
            for child in snapshot.children {
                guard let base = child as? DataSnapshot,
                      let dict = base.value as? [String: Any],
                      let buddy = BuddyUserModel.getObject(dict: dict)
                else {
                    continue
                }
                buddies.append(buddy)
            }
            if snapshot.childrenCount != buddies.count {
                print("SearchService: Couldn't parse a some Buddies")
            }
            print("SearchService: Fetched buddy List - Success")
            completion(.success(buddies))
        }
    }
    
    func makeBuddy(for members: [String],threadId: String, completion:@escaping SuccessCompletion) {
        guard members.count == 2 else {
            completion(false)
            return
        }
        let member1 = members[0]
        let member2 = members[1]
        let addUserCompletion: (Bool)->Void = { success in
            if !success {
                completion(false)
            }
        }
        addUserToBuddyList(for: member1, with: BuddyUserModel(email: member2, convoId: threadId), completion: addUserCompletion)
        addUserToBuddyList(for: member2, with: BuddyUserModel(email: member1, convoId: threadId), completion: addUserCompletion)
        completion(true)
    }
    
    private func addUserToBuddyList(for email: String,with buddy:BuddyUserModel, completion: @escaping SuccessCompletion) {
        guard !email.isEmpty, let email = Utils.shared.safeEmail(email: email)
        else {
            
            completion(false)
            return
        }
        let ref = database.child(getBuddlyListPath(safeEmail: email)).childByAutoId()
        ref.setValue(buddy.serialisedObject()) { err, _ in
            if err != nil {
                completion(false)
                print("SearchService: Added To Buddy List Failed")
            }
            completion(true)
        }
    }
}

extension SearchService {
    private func getBuddlyListPath(safeEmail: String) -> String {
        return "\(safeEmail)/\(Constants.DbPathBuddyList)"
    }
}

