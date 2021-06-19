//
//  ProfileViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 19/06/21.
//

import Foundation
import UIKit

enum ProfileActionType {
    case blockedContactList
    case blockContact
    case settings
}

class ProfileViewModel {
    let offlinePresenceImage: UIImage
    let onlinePresenceImage: UIImage
    let profileImageName = Constants.ImageNamePersonPlaceholder
    let isProfileOfLoggedInUser: Bool
    let personModel: ChatAppUserModel
    
    var tableData = [ProfileActionType]()
    
    init(isProfileOfLoggedInUser: Bool = false, userModel: ChatAppUserModel) {
        offlinePresenceImage = UIColor.systemYellow.image()
        onlinePresenceImage = UIColor.systemGreen.image()
        self.isProfileOfLoggedInUser = isProfileOfLoggedInUser
        personModel = userModel
        
        configureTableData()
    }
    
    var isUserOnline: Bool {
        let onlineUsers = PresenceManager.shared.onlineUsers
        return onlineUsers.contains(personModel.email)
    }
}

extension ProfileViewModel {
    private func configureTableData() {
        if isProfileOfLoggedInUser {
            tableData.append(.settings)
            tableData.append(.blockedContactList)
        }
        else {
            tableData.append(.blockContact)
        }
    }
}
