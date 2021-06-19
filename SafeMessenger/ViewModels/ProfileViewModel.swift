//
//  ProfileViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 19/06/21.
//

import Foundation
import UIKit

enum ProfileActionType {
    case blockContact
    case about
}

class ProfileViewModel {
    let offlinePresenceImage: UIImage
    let onlinePresenceImage: UIImage
    let profileImageName = Constants.ImageNamePersonPlaceholder
    let isProfileOfLoggedInUser: Bool
    let personModel: ChatAppUserModel
    
    var aboutString: String
    var tableData = [ProfileActionType]()
    
    init(isProfileOfLoggedInUser: Bool = false, userModel: ChatAppUserModel) {
        offlinePresenceImage = UIColor.systemYellow.image()
        onlinePresenceImage = UIColor.systemGreen.image()
        self.isProfileOfLoggedInUser = isProfileOfLoggedInUser
        personModel = userModel
        aboutString = Constants.defaultAboutString
        configureTableData()
    }
    
    var isUserOnline: Bool {
        let onlineUsers = PresenceManager.shared.onlineUsers
        return onlineUsers.contains(personModel.email)
    }
    
    func getAboutString(for email:String, completion: @escaping ResultStringCompletion) {
        DispatchQueue.background(background: {[weak self] in
            ApiHandler.shared.fetchAboutString(for: self?.personModel.email ?? "") {[weak self] res in
                switch res {
                case .failure(_):
                    break
                case .success(let aboutString):
                    self?.aboutString = aboutString
                }
            }
        })
    }
}

extension ProfileViewModel {
    private func configureTableData() {
        if isProfileOfLoggedInUser {
            tableData.append(.about)
        }
        else {
            tableData.append(.about)
            tableData.append(.blockContact)
        }
    }
}
