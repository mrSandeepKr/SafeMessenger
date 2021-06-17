//
//  ChatListMultiViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 23/05/21.
//

import Foundation
import UIKit
import SDWebImage

class ChatListMultiViewModel {
    var hamburgerBtnImagePlaceholder: String?
    
    init() {
        hamburgerBtnImagePlaceholder = Constants.ImageNamePersonPlaceholder
    }
    
    public var isLoggedIn: Bool {
        return Utils.shared.isUserLoggedIn()
    }
    
    func updateHamburgerBtnImageView(for imageView: UIImageView) {
        StorageManager.shared.downloadImageURLandUpdateView(for: imageView, path: StorageManager.profileImagePath)
    }
    
    func getChatViewModel(for convo: ConversationObject) -> ChatViewModel?  {
        guard let loggedInUser = Utils.shared.getLoggedInUserEmail() else {
            return nil
        }
        let members = convo.members.filter{return $0 != loggedInUser}
        guard members.count > 0 else {
            return nil
        }
        return ChatViewModel(memberEmail: members[0], convoID: convo.convoID)
    }
}
