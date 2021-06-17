//
//  ChatAppUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation

class ChatAppUserModel {
    let firstName: String
    let secondName: String
    let email: String
    
    init(firstName: String, secondName: String, email: String) {
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
    }
    
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
}
