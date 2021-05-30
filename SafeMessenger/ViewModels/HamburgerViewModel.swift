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
    public var profileImage: UIImage?
    public var hamburgerBackground: UIImage
    
    init() {
        profileImage = UIImage(named: "personPlaceholder")
        hamburgerBackground = UIImage(named: "hamburgerBackground")!
    }
}
