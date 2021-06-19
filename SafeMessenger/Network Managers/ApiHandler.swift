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

public enum ApiHandlerErrors: Error {
    case FailedSafeEmailGnrtn
    case FailedToGetUser
    case FailedToGetAboutString
}

final class ApiHandler {
    static let shared = ApiHandler()
    
    private let database = Database.database(url: URLStrings.databaseURL).reference()
}

//MARK: SignIn & SignOut Support
extension ApiHandler {
    /// Adds user's firstName, Second Name to Database
    public func insertUserToDatabase(user: ChatAppUserModel, completion: @escaping SuccessCompletion) {
        let userDict = user.serialisedObject()
        database.child(user.safeEmail).setValue(userDict) { err, _ in
            guard err == nil else {
                print("ApiHandler: User insertion to database Failed")
                completion(false)
                return
            }
            print("ApiHandler: User insertion to database Success")
            completion(true)
        }
    }
    
    public func setUserImageURLInDatabase(email: String, imageURL: String, completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.safeEmail(email: email)
        else {
            completion(false)
            return
        }
        database.child(safeEmail).child(Constants.imageURL).setValue(imageURL) { err, _ in
            guard err == nil else {
                completion(false)
                return
            }
            completion(true)
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
    public func insertUserToSearchArray(user: ChatAppUserModel, completion: @escaping SuccessCompletion) {
        let ref = self.database.child(Constants.DbPathUsers).childByAutoId()
        let newUser = user.serialisedObject()
        ref.setValue(newUser) { err, _ in
            guard err == nil else {
                print("ApiHandler: User insertion to Users Array Failed")
                completion(false)
                return
            }
            print("ApiHandler: User insertion to Users Array Success")
            completion(true)
        }
    }
    
    func createUserOnFirebase(email: String, pswd: String, completion: @escaping StringCompletion) {
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
            PresenceManager.shared.moveOffline()
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


//MARK: Search Support APIs
extension ApiHandler {
    func fetchUserInfo(for email:String, completion: @escaping FetchUserCompletion) {
        guard let safeEmail = Utils.shared.safeEmail(email: email) else {
            completion(.failure(ApiHandlerErrors.FailedSafeEmailGnrtn))
            return
        }
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("ApiHandler: Fetch UserInfo Failed - to find userInfo")
                completion(.failure(ApiHandlerErrors.FailedToGetUser))
                return
            }
            guard let user = ChatAppUserModel.getObject(from: value)
            else {
                print("ApiHandler: Fetch UserInfo Failed - unable to parse data")
                completion(.failure(ApiHandlerErrors.FailedToGetUser))
                return
            }
            print("ApiHandler: Fetch UserInfo Success")
            completion(.success(user))
        }
    }
    
    func fetchLoggedInUserInfoAndSetDefaults(for email:String, completion:@escaping SuccessCompletion) {
        fetchUserInfo(for: email) {[weak self] res in
            switch res {
            case .success(let model):
                self?.setUserLoggedInDefaults(user: model)
                completion(true)
                print("ApiHandler: logged In user fetch - Sucess")
                break
            default:
                print("ApiHandler: logged In user  fetch - Failed")
                break
            }
        }
    }
    
    func fetchAboutString(for email:String, completion: @escaping ResultStringCompletion) {
        guard let safeEmail = Utils.shared.safeEmail(email: email) else {
            completion(.failure(ApiHandlerErrors.FailedSafeEmailGnrtn))
            return
        }
        let ref = database.child("\(safeEmail)/\(Constants.DbPathAboutString)")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let aboutString = snapshot.value as? String,
                  !aboutString.isEmpty
            else {
                print("ApiHandler: Fetch About String Failed")
                completion(.failure(ApiHandlerErrors.FailedToGetAboutString))
                return
            }
            print("ApiHandler: Fetch About String Success")
            completion(.success(aboutString))
        }
    }
}

//MARK: Utils
extension ApiHandler {
    public func userExists(with email: String, completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.safeEmail(email: email) else {
            completion(false)
            return
        }
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    private func resetUserDefaults() {
        print("ApiHandler: Resetting User Defaults")
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func setUserLoggedInDefaults(user:ChatAppUserModel) {
        let dict = [
            UserDefaultConstant.userName: user.displayName,
            UserDefaultConstant.userEmail: user.email,
            UserDefaultConstant.profileImageUrl: user.imageURLString,
            UserDefaultConstant.isLoggedIn: true
        ] as [String : Any]
        
        UserDefaults.standard.setValuesForKeys(dict)
        print("ApiHandler: Setting User Defaults For Signing in user")
    }
    
    func setWarmUpDefaults(with email: String) {
        let dict = [
            UserDefaultConstant.userEmail: email,
            UserDefaultConstant.isLoggedIn: true
        ] as [String : Any]
        
        UserDefaults.standard.setValuesForKeys(dict)
        print("ApiHAndler: Set Warm Up Defaults Success")
    }
}
