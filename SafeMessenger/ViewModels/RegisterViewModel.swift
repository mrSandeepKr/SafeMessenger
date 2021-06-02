//
//  RegisterViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import UIKit
import FirebaseAuth

class RegisterViewModel {
    public let backgroundImage: UIImage?
    public let profileImage: UIImage?
    typealias CreateAccountCompletion = (String) -> Void
    
    init() {
        let isDarkMode = (UITraitCollection.current.userInterfaceStyle == .dark)
        backgroundImage = isDarkMode  ? UIImage(named: "registerBackgroundDark"): UIImage(named: "registerBackground")
        profileImage = UIImage(named: "personPlaceholder")
    }
    
    public func handleAccountCreation(firstName: String?,
                                      secondName: String?,
                                      emailAddress: String?,
                                      password: String?,
                                      verifyPassword:String?,
                                      completion: @escaping  CreateAccountCompletion) {
        var msg = ""
        guard let fn = firstName?.trimmingCharacters(in: .whitespaces),
              let sn = secondName?.trimmingCharacters(in: .whitespaces),
              let email = emailAddress?.trimmingCharacters(in: .whitespaces),
              let pswd = password, let vpswd = verifyPassword,
              !fn.isEmpty, !sn.isEmpty, !email.isEmpty, !pswd.isEmpty, !vpswd.isEmpty
        else {
            msg = "Non of the fields should be empty"
            completion(msg)
            return
        }
        
        if pswd.count < 5 {msg = "Password should be 5 letters long"}
        else if pswd != vpswd {msg = "Password and verified Password don't match"}
        else if !email.isValidEmail() {msg = "Enter a valid email Id"}
        else if !fn.isValidName(), !sn.isValidName() {msg = "Enter appropriate Name and Second Name"}
        
        if !msg.isEmpty {
            completion(msg)
            return
        }
        
        handleUserCreation(email: email, pswd: pswd) { msg in
            if msg.isEmpty {
                ApiHandler.shared.insertUser(user: ChatAppUserModel(firstName: fn,
                                                                    secondName: sn,
                                                                    email:email))
                completion("")
                return
            }
            completion(msg)
        }
    }
    
    private func handleUserCreation(email: String, pswd: String, completion: @escaping CreateAccountCompletion) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: pswd) { authResult, err in
            guard err == nil else {
                completion(err!.localizedDescription)
                return
            }
            
            UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
            completion("")
        }
    }
}