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
    case FailedToFetchAllUsers
    case FailedSafeEmailGnrtn
    case FailedToGetUser
}

final class ApiHandler {
    static let shared = ApiHandler()
    
    private let database = Database.database(url: URLStrings.databaseURL).reference()
}

//MARK: SignIn & SignOut Support
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
        self.database.child(Constants.users).observeSingleEvent(of: .value) {[weak self] snapshot in
            guard let strongSelf = self else {
                completion(false)
                return
            }
            let newElement = user.serialisedObject()
            var collections = UsersDictList()
            
            if var userCollection = snapshot.value as? UsersDictList {
                // Append to users Array
                userCollection.append(newElement)
                collections = userCollection
            }
            else {
                // create the user Array
                collections = [newElement]
            }
            
            strongSelf.database.child(Constants.users).setValue(collections) { err, _ in
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
    func fetchAllUsers(completion: @escaping FetchAllUsersCompletion) {
        database.child(Constants.users).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? UsersDictList else {
                print("ApiHandler: Fetch All users Failed")
                completion(.failure(ApiHandlerErrors.FailedToFetchAllUsers))
                return
            }
            let userObjects = value.compactMap{return ChatAppUserModel.getObject(from: $0)}
            if userObjects.count != value.count {
                print("ApiHanlder: Fetch All User - Some Users not resolved")
            }
            print("ApiHandler: Fetch All users Success")
            completion(.success(userObjects))
        }
    }
    
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
            guard let firstName = value[Constants.firstName] as? String,
                  let secondName = value[Constants.secondName] as? String
            else {
                print("ApiHandler: Fetch UserInfo Failed - unable to parse data")
                completion(.failure(ApiHandlerErrors.FailedToGetUser))
                return
            }
            print("ApiHandler: Fetch UserInfo Success")
            completion(.success(ChatAppUserModel(firstName: firstName,
                                                 secondName: secondName,
                                                 email: email)))
        }
    }
    
    func fetchLoggedInUserInfoAndSetDefaults(for email:String, completion:@escaping (Bool)->Void) {
        fetchUserInfo(for: email) { res in
            switch res {
            case .success(let model):
                StorageManager.shared.getDownloadURLString(for: model.profileImageRefPathForUser) {[weak self] res in
                    switch res {
                    case .success(let url):
                        self?.setUserLoggedInDefaults(user: model, downloadURL: url)
                        completion(true)
                        print("ApiHandler: logged In user downloadURL fetch - Sucess")
                        break
                    default:
                        print("ApiHandler: logged In user downloadURL fetch - Failed")
                        break
                    }
                }
                break
            default:
                break
            }
        }
    }
}

//MARK: Utils
extension ApiHandler {
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
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
    
    func setUserLoggedInDefaults(user:ChatAppUserModel, downloadURL: String) {
        let dict = [
            UserDefaultConstant.userName: user.displayName,
            UserDefaultConstant.userEmail: user.email,
            UserDefaultConstant.profileImageUrl: downloadURL,
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
