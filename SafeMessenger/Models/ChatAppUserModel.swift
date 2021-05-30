//
//  ChatAppUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation

struct ChatAppUserModel {
    let firstName: String
    let secondName: String
    let email: String
    
    var safeEmail: String {
        return (email.replacingOccurrences(of: ".", with: "-"))
    }
}
