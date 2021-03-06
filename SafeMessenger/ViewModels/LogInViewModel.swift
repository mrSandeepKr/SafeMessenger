//
//  LogInViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation

class LogInViewModel {
    public func logInUser(with email:String?, password: String?,completion: @escaping (String?)->Void) {
        guard let email = email?.trimmingCharacters(in: .whitespaces).lowercased(), let pswd = password,
              !email.isEmpty, !pswd.isEmpty
        else {
            completion("Email or password field cannot be empty")
            return
        }
        
        ApiHandler.shared.fireBaseSignIn(email: email, pswd: pswd) {msg in
            guard msg == nil else {
                completion(msg)
                return
            }
            ApiHandler.shared.setWarmUpDefaults(with: email)
            ApiHandler.shared.fetchLoggedInUserInfoAndSetDefaults(for: email) { success in
                guard success else {
                    completion("Hey we couldn't fetch you userInfo while signing you in")
                    return
                }
                completion(nil)
            }
        }
    }
    
    func googleSignUser() {
        ApiHandler.shared.googleSignInUser()
    }
}
