//
//  ChatAppUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation

struct ChatAppUserModel: Serialisable {
    let firstName: String
    let secondName: String
    let email: String
    
    var safeEmail: String {
        return (email.replacingOccurrences(of: ".", with: "-"))
    }
    
    var profileImageString: String {
            return StorageManager.profileImageFilename(for: safeEmail)
    }
    
    var profileImageRefPathForUser: String {
        let fileName =  StorageManager.profileImageFilename(for: safeEmail)
        return StorageManager.profileImageRefPath(fileName: fileName)
    }
    
    var displayName: String {
        return "\(firstName) \(secondName)"
    }
    
    static func getObject(from dict: [String: Any]) -> ChatAppUserModel? {
        guard let displayName = dict[Constants.displayName] as? String,
              let email = dict[Constants.email] as? String
        else {
            return nil
        }
        let split = displayName.split(separator: " ").map{ return String($0)}
        return ChatAppUserModel(firstName: split[0],
                                secondName: split[1],
                                email: email)
    }
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.displayName: displayName,
            Constants.email: email
        ]
    }
}
