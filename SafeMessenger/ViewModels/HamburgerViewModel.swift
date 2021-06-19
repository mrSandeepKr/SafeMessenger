//
//  HamburgerViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation
import UIKit

class HamburgerViewModel {
    // MARK: Properties
    var profileImageName: String
    var hamburgerBackgroundImageName: String
    
    init() {
        profileImageName = Constants.ImageNamePersonPlaceholder
        hamburgerBackgroundImageName = Constants.ImageNameHamburgerBackgroud
    }
    
    func updateProfileImageView(for imageView:UIImageView) {
        StorageManager.shared.downloadImageURLandUpdateView(for: imageView,
                                                            path: StorageManager.profileImagePath)
    }
    
    func handleSignOutTapped(completion: (Bool)->()) {
        ApiHandler.shared.signOutUser(completion: completion)
    }
    
    func userNameLabelString() -> String {
        return Utils.shared.getLoggedInUserDisplayName() ?? Constants.unknownUser
    }
    
    func emailLabelString() -> String {
        return Utils.shared.getLoggedInUserEmail() ?? Constants.unknownUser
    }
}
