//
//  BuddyUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 17/06/21.
//

import Foundation

class BuddyUserModel: Serialisable {
    let email: String
    let convoId: String
    
    init(email: String, convoId: String) {
        self.email = email
        self.convoId = convoId
    }
    
    static func getObject(dict: [String: Any]) -> BuddyUserModel? {
        guard let email = dict[Constants.email] as? String,
              let convoId = dict[Constants.convoID] as? String
        else {
            return nil
        }
        return BuddyUserModel(email: email, convoId: convoId)
    }
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.convoID: convoId,
            Constants.email: email
        ]
    }
}
