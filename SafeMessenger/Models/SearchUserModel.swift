//
//  SearchUserModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 17/06/21.
//

import Foundation

class SearchUserModel: ChatAppUserModel, Serialisable {
    let imageURLString: String
    
    init(firstName: String, secondName: String, email: String, imageURLString: String) {
        self.imageURLString = imageURLString
        super.init(firstName: firstName, secondName: secondName, email: email)
    }
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.firstName: firstName,
            Constants.secondName: secondName,
            Constants.imageURL: imageURLString,
            Constants.email: email
        ]
    }
    
    static func getObject(from dict: [String: Any]) -> SearchUserModel? {
        guard let firstName = dict[Constants.firstName] as? String,
              let secondName = dict[Constants.secondName] as? String,
              let email = dict[Constants.email] as? String,
              let imageURLString = dict[Constants.imageURL] as? String
        else {
            return nil
        }
        return SearchUserModel(firstName: firstName,
                               secondName: secondName,
                               email: email,
                               imageURLString: imageURLString)
    }
    
    static func getObject(for user:ChatAppUserModel,imageUrlString:String) -> SearchUserModel {
        return SearchUserModel(firstName: user.firstName,
                               secondName: user.secondName,
                               email: user.email,
                               imageURLString: imageUrlString)
    }
}
