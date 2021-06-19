//
//  ChatAppUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation

class ChatAppUserModel: Serialisable {
    
    let firstName: String
    let secondName: String
    let email: String
    let imageURLString: String
    
    init(firstName: String, secondName: String, email: String, imageURLString: String = "") {
        self.firstName = firstName
        self.secondName = secondName
        self.email = email
        self.imageURLString = imageURLString
    }
    
    var safeEmail: String {
        return (email.replacingOccurrences(of: ".", with: "-"))
    }
    
    var profileImageString: String {
        return StorageManager.profileImageFilename(for: safeEmail)
    }
    
    var profileImageRefPathForUser: String {
        let fileName =  StorageManager.profileImageFilename(for: safeEmail)
        return StorageManager.profileImageRefPath(fileName: fileName)
    }
    
    var displayName: String {
        return "\(firstName) \(secondName)"
    }
    
    var imageURL: URL {
        return URL(string: imageURLString)!
    }
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.firstName: firstName,
            Constants.secondName: secondName,
            Constants.imageURL: imageURLString,
            Constants.email: email
        ]
    }
    
    static func getLoggedInUserModel() -> ChatAppUserModel? {
        guard let displaName = Utils.shared.getLoggedInUserDisplayName(),
              let email = Utils.shared.getLoggedInUserEmail(),
              let imageUrlString = Utils.shared.getLoggedInUserDisplayURL()
        else {
            return nil
        }
        let split = displaName.split(separator: " ")
        let firstName = String(split[0])
        let secondName = String(split[1])
        
        return ChatAppUserModel(firstName: firstName,
                                secondName: secondName,
                                email: email,
                                imageURLString: imageUrlString)
    }
    
    static func getObject(from dict: [String: Any]) -> ChatAppUserModel? {
        guard let firstName = dict[Constants.firstName] as? String,
              let secondName = dict[Constants.secondName] as? String,
              let email = dict[Constants.email] as? String,
              let imageURLString = dict[Constants.imageURL] as? String
        else {
            return nil
        }
        return ChatAppUserModel(firstName: firstName,
                                secondName: secondName,
                                email: email,
                                imageURLString: imageURLString)
    }
    
    static func getObject(for user:ChatAppUserModel,imageUrlString:String) -> ChatAppUserModel {
        return ChatAppUserModel(firstName: user.firstName,
                                secondName: user.secondName,
                                email: user.email,
                                imageURLString: imageUrlString)
    }
}
