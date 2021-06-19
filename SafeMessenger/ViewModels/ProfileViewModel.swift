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
    
    var email: String?
    var userName: String?
    var imageURL: String?
    
    init(isProfileOfLoggedInUser: Bool = false) {
        offlinePresenceImage = UIColor.systemYellow.image()
        onlinePresenceImage = UIColor.systemGreen.image()
        self.isProfileOfLoggedInUser = isProfileOfLoggedInUser
        
        email = Utils.shared.getLoggedInUserEmail()
        userName = Utils.shared.getLoggedInUserDisplayName()
        imageURL = Utils.shared.getLoggedInUserDisplayURL()
    }
}
