//
//  RegisterViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import UIKit

class RegisterViewModel {
    var backgroundImageName: String?
    var profileImageName: String?
    
    init() {
        let isDarkMode = (UITraitCollection.current.userInterfaceStyle == .dark)
        backgroundImageName = isDarkMode  ? "registerBackgroundDark": "registerBackground"
        profileImageName =  Constants.ImageNamePersonPlaceholder
    }
    
    ///
    public func handleAccountCreation(firstName: String?,
                                      secondName: String?,
                                      emailAddress: String?,
                                      password: String?,
                                      verifyPassword: String?,
                                      profileImage: UIImage?,
                                      completion: @escaping StringCompletion) {
        var msg = ""
        guard let fn = firstName?.trimmingCharacters(in: .whitespaces),
              let sn = secondName?.trimmingCharacters(in: .whitespaces),
              let email = emailAddress?.trimmingCharacters(in: .whitespaces),
              let pswd = password, let vpswd = verifyPassword,
              let image = profileImage,
              let data = image.pngData(),
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
        
        handleUserCreation(email: email.lowercased(),
                           pswd: pswd,firstName:
                            fn, secondName: sn,
                           profileImageData: data,
                           completion: completion)
    }
}

extension RegisterViewModel {
    private func handleUserCreation(email: String,
                                    pswd: String,
                                    firstName: String,
                                    secondName: String,
                                    profileImageData: Data,
                                    completion: @escaping StringCompletion) {
        ApiHandler.shared.createUserOnFirebase(email: email, pswd: pswd) { msg in
            guard msg.isEmpty else {
                completion(msg)
                return
            }
            print("RegisterViewModel: Firebase user Creation was a success")
            let userInfo = ChatAppUserModel(firstName: firstName,
                                            secondName: secondName,
                                            email:email)
            
            print("RegisterViewModel: Added User Info to Database")
            StorageManager.shared.uploadUserProfileImage(with: profileImageData,
                                                         fileName: userInfo.profileImageString) { res in
                switch res {
                case .success(let downloadUrl):
                    let userCopy = ChatAppUserModel.getObject(for: userInfo, imageUrlString: downloadUrl)
                    ApiHandler.shared.insertUserToDatabase(user: userCopy) { _ in}
                    ApiHandler.shared.setUserLoggedInDefaults(user: userCopy)
                    ApiHandler.shared.insertUserToSearchArray(user: userCopy,
                                                              completion: {_ in})
                    completion("")
                case .failure(_):
                    completion("Oops!! Failed to upload your profile Image to Database")
                }
            }
        }
    }
}
