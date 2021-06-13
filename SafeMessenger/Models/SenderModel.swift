//
//  SenderModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation
import MessageKit

extension SenderType {
    func serialisedObject() -> [String : Any] {
        return [
            Constants.imageURL: Utils.shared.getStorageUrlForEmail(for: senderId),
            Constants.senderID: senderId,
            Constants.displayName: displayName
        ]
    }
    
    func getSenderFirstName() -> String? {
        let split = displayName.split(separator: " ").map { return String($0)}
        guard split.count > 0 else {
            return nil
        }
        return split[0]
    }
}

struct Sender: SenderType, Serialisable {
    var imageURL: String
    var senderId: String
    var displayName: String
    
    func serialisedObject() -> [String : Any] {
        return [
            Constants.imageURL: imageURL,
            Constants.senderID: senderId,
            Constants.displayName: displayName
        ]
    }
    
    static func getObject(from dict: [String: Any]) -> Sender? {
        guard let imageURL = dict[Constants.imageURL] as? String,
              let displayName = dict[Constants.displayName] as? String,
              let senderID = dict[Constants.senderID] as? String
        else {
            return nil
        }
        return Sender(imageURL: imageURL,
                      senderId: senderID,
                      displayName: displayName)
    }
}
