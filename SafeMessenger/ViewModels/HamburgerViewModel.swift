//
//  HamburgerViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 29/05/21.
//

import Foundation
import UIKit
import FirebaseAuth
class HamburgerViewModel {
    // MARK: Properties
    public var profileImage: UIImage?
    public var hamburgerBackground: UIImage
    
    init() {
        profileImage = UIImage(named: "personPlaceholder")
        hamburgerBackground = UIImage(named: "hamburgerBackground")!
    }
    
    public func handleSignOutTapped(completion: (Bool)->()) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            UserDefaults.standard.setValue(false, forKey: "isLoggedIn")
            completion(true)
        }
        catch {
            completion(false)
        }
    }
}
