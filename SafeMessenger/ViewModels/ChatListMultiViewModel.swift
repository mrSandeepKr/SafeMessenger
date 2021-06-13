//
//  ChatListMultiViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import UIKit

class ChatListMultiViewModel {
    var hamburgerBtnImagePlaceholder: String?
    
    init() {
        hamburgerBtnImagePlaceholder = Constants.ImageNamePersonPlaceholder
    }
    
    public var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultConstant.isLoggedIn)
    }
    
    func updateHamburgerBtnImageView(for imageVIew: UIImageView) {
        StorageManager.shared.downloadImageURLandUpdateView(for: imageVIew,
                                                            path: StorageManager.profileImagePath)
    }
}
