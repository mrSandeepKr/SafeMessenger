//
//  HamburgerViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation
import UIKit

enum HambrgrCellType {
    case account
    case settings
    case about
    case blockedContacts
}

class HamburgerViewModel {
    // MARK: Properties
    var profileImageName: String
    var hamburgerBackgroundImageName: String
    var tableViewData = [HambrgrCellType]()
    
    init() {
        profileImageName = Constants.ImageNamePersonPlaceholder
        hamburgerBackgroundImageName = Constants.ImageNameHamburgerBackgroud
        tableViewData = [.account, .about,.settings,.blockedContacts]
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

extension HamburgerViewModel {
    func getAttributedString(for cellType: HambrgrCellType) -> NSAttributedString {
        let string = NSMutableAttributedString(string: "")
        switch cellType {
        case .account:
            let attachment = NSTextAttachment(image: UIImage(systemName: "person")!)
            let attachmentString = NSAttributedString(attachment: attachment)
            string.append(attachmentString)
            string.append(NSAttributedString(string: " Account"))
        case .settings:
            let attachment = NSTextAttachment(image: UIImage(systemName: "gear")!)
            let attachmentString = NSAttributedString(attachment: attachment)
            string.append(attachmentString)
            string.append(NSAttributedString(string: " Settings"))
        case .about:
            let attachment = NSTextAttachment(image: UIImage(systemName: "pencil.and.outline")!)
            let attachmentString = NSAttributedString(attachment: attachment)
            string.append(attachmentString)
            string.append(NSAttributedString(string: " About"))
        case .blockedContacts:
            let attachment = NSTextAttachment(image: UIImage(systemName: "xmark.shield.fill")!)
            let attachmentString = NSAttributedString(attachment: attachment)
            string.append(attachmentString)
            string.append(NSAttributedString(string: " Blocked Contacts"))
        }
        return string
    }
}
