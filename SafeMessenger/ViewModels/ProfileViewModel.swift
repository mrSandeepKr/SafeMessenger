//
//  ProfileViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 19/06/21.
//

import Foundation
import UIKit

class ProfileViewModel {
    let offlinePresenceImage: UIImage
    let onlinePresenceImage: UIImage
    let profileImageName = Constants.ImageNamePersonPlaceholder
    let isProfileOfLoggedInUser: Bool
    
    let personModel: ChatAppUserModel
    
    init(isProfileOfLoggedInUser: Bool = false, userModel: ChatAppUserModel) {
        offlinePresenceImage = UIColor.systemYellow.image()
        onlinePresenceImage = UIColor.systemGreen.image()
        self.isProfileOfLoggedInUser = isProfileOfLoggedInUser
        personModel = userModel
    }
}
