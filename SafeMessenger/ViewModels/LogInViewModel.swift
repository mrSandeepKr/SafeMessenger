//
//  LogInViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

class LogInViewModel {
    public func logInUser(with email:String?, password: String?,completion: @escaping (String?)->Void) {
        guard let email = email?.trimmingCharacters(in: .whitespaces), let pswd = password,
              !email.isEmpty, !pswd.isEmpty
        else {
            completion("Email or password field cannot be empty")
            return
        }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: pswd) {[weak self] res, err in
            guard err == nil else {
                if err != nil {
                    completion(err?.localizedDescription)
                }
                else {
                    completion("Something went wrong try Again")
                }
                return
            }
            
            self?.setUserDefaultsForLogin()
            completion(nil)
        }
    }
    
    func setUserDefaultsForLogin() {
        UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
    }
    
    func googleSignUser() {
        GIDSignIn.sharedInstance().signIn()
    }
}
