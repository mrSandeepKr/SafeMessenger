//
//  PresenceManager.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 19/06/21.
//

import Foundation
import FirebaseDatabase

class PresenceManager {
    static let shared = PresenceManager()
    
    let database = Database.database(url: URLStrings.databaseURL).reference()
    var child: DatabaseReference?
    var onlineUsers = [String]()
    
    init() {
        addObserverOnOnlineUsers { _ in}
    }
}

extension PresenceManager {
    func moveOnline() {
        guard let loggedInUserEmail = Utils.shared.getLoggedInUserEmail(),
              self.child == nil
        else {
            return
        }
        
        let child = database.child(Constants.DbPathOnlineUsers).childByAutoId()
        self.child = child
        child.setValue(loggedInUserEmail)
        child.ref.onDisconnectRemoveValue()
    }
    
    func moveOffline() {
        guard let child = self.child else {
            return
        }
        child.removeValue()
        self.child = nil
    }
    
    private func addObserverOnOnlineUsers(completion: @escaping (Result<[String],Error>) -> Void) {
        let ref = database.child(Constants.DbPathOnlineUsers)
        ref.observe(.value) { snapshot in
            var onlineUsers = [String]()
            for child in snapshot.children {
                guard let base = child as? DataSnapshot,
                      let value = base.value as? String
                else {
                    continue
                }
                onlineUsers.append(value)
            }
            print("PresenceManager: Fetch Presence Success")
            self.onlineUsers = onlineUsers
            NotificationCenter.default.post(name: .onlineUserSetChangeNotification, object: nil, userInfo: nil)
            completion(.success(onlineUsers))
            return
        }
    }
}
