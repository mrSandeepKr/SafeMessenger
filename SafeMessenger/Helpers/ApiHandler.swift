//
//  ApiHandler.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import FirebaseDatabase



struct ChatAppUserModel {
    let firstName: String
    let secondName: String
    let email: String
    
    var safeEmail: String {
        return (email.replacingOccurrences(of: ".", with: "-"))
    }
}

final class ApiHandler {
    static let shared = ApiHandler()
    
    private let database = Database.database(url: Constants.databaseURL).reference()
    
    public func insertUser(user: ChatAppUserModel) {
        database.child(user.safeEmail).setValue([
            Constants.firstName: user.firstName,
            Constants.secondName: user.secondName
        ])
    }
}
