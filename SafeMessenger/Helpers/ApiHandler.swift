//
//  ApiHandler.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn


typealias CreateAccountCompletion = (String) -> Void

final class ApiHandler {
    static let shared = ApiHandler()
    
    private let database = Database.database(url: URLStrings.databaseURL).reference()
    
    static func safeEmail(emailAddress: String) -> String {
        return emailAddress.replacingOccurrences(of: ".", with: "-")
    }
}

extension ApiHandler {
    /// Adds user's firstName, Second Name to Database
    public func insertUserToDatabase(user: ChatAppUserModel, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            Constants.firstName: user.firstName,
            Constants.secondName: user.secondName
        ]) { err, _ in
            guard err == nil else {
                print("ApiHandler: User insertion to database Failed")
                completion(false)
                return
            }
            print("ApiHandler: User insertion to database Success")
            completion(true)
        }
    }
    
    func createUserOnFirebase(email: String, pswd: String, completion: @escaping CreateAccountCompletion) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pswd) { _, err in
            guard err == nil else {
                completion(err!.localizedDescription)
                return
            }
            completion("")
        }
    }
    
    func fireBaseSignIn(email: String, pswd: String, completion: @escaping (String?) -> Void) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pswd) { _, err in
            guard err == nil else {
                if err != nil {
                    completion(err?.localizedDescription)
                }
                else {
                    completion("Something went wrong try Again")
                }
                return
            }
            completion(nil)
        }
    }
    
    func signOutUser(completion: (Bool)->()) {
        do {
            GIDSignIn.sharedInstance().signOut()
            try FirebaseAuth.Auth.auth().signOut()
            completion(true)
        }
        catch {
            completion(false)
        }
    }
    
    func googleSignInUser() {
        GIDSignIn.sharedInstance().signIn()
    }
}

extension ApiHandler {
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = ApiHandler.safeEmail(emailAddress: email)
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
}
