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
    let DBUserPath: String = "users"
}

extension ApiHandler {
    /// Adds user's firstName, Second Name to Database
    public func insertUserToDatabase(user: ChatAppUserModel, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            Constants.firstName: user.firstName,
            Constants.secondName: user.secondName
        ]) { [weak self] err, _ in
            guard err == nil else {
                print("ApiHandler: User insertion to database Failed")
                completion(false)
                return
            }
            print("ApiHandler: User insertion to database Success")
            self?.insertUserToUserArray(user: user, completion: completion)
        }
    }
    
    /// Add user Info to user Array, This is required to enable the user search.
    /// User Array ->
    /// [
    ///     [
    ///     name : "SK",
    ///     email : "sk@gmail.com"
    ///     ]
    /// ]
    public func insertUserToUserArray(user: ChatAppUserModel, completion: @escaping (Bool) -> Void ) {
        self.database.child(DBUserPath).observeSingleEvent(of: .value) {[weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            let newElement = [
                Constants.name: user.firstName + " " + user.secondName,
                Constants.email: user.email
            ]
            
            var collections = [[String:String]]()
            
            if var userCollection = snapshot.value as? [[String: String]] {
                // Append to users Array
                userCollection.append(newElement)
                collections = userCollection
            }
            else {
                // create the user Array
                collections = [newElement]
            }
            
            strongSelf.database.child(strongSelf.DBUserPath).setValue(collections) { err, _ in
                guard err == nil else {
                    print("ApiHandler: User insertion to Users Array Failed")
                    completion(false)
                    return
                }
                print("ApiHandler: User insertion to Users Array Success")
                completion(true)
            }
        }
    }
    
    func createUserOnFirebase(email: String, pswd: String, completion: @escaping CreateAccountCompletion) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pswd) { _, err in
            guard err == nil else {
                completion(err!.localizedDescription)
                return
            }
            UserDefaults.standard.setValue(email, forKey: UserDefaultConstant.userEmail)
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
            UserDefaults.standard.setValue(email, forKey: UserDefaultConstant.userEmail)
            completion(nil)
        }
    }
    
    func signOutUser(completion: (Bool)->()) {
        do {
            GIDSignIn.sharedInstance().signOut()
            try FirebaseAuth.Auth.auth().signOut()
            resetUserDefaults()
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
    
    private func resetUserDefaults() {
        let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                defaults.removeObject(forKey: key)
            }
    }
}
