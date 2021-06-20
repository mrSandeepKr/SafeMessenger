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
    case address
    case secondaryEmail
    case phoneNumber
}

class ProfileCardModel {
    var about: String = Constants.defaultAboutString
    var address: String = Constants.defaultAddressString
    var number: String = Constants.defaultPhoneNumerString
    var secondaryEmail: String = Constants.defaultSecondaryEmail
    
    init() {
    }
    
    convenience init(about: String?, address: String?, number: String?, secondaryEmail: String?) {
        self.init()
        self.about = about ?? Constants.defaultAboutString
        self.address = address ?? Constants.defaultAddressString
        self.number = number ?? Constants.defaultPhoneNumerString
        self.secondaryEmail = secondaryEmail ?? Constants.defaultSecondaryEmail
    }
}

class ProfileViewModel {
    let offlinePresenceImage: UIImage
    let onlinePresenceImage: UIImage
    let profileImageName = Constants.ImageNamePersonPlaceholder
    let isProfileOfLoggedInUser: Bool
    let personModel: ChatAppUserModel
    
    var profileCardData: ProfileCardModel
    var tableData = [ProfileActionType]()
    
    init(isProfileOfLoggedInUser: Bool = false, userModel: ChatAppUserModel) {
        offlinePresenceImage = UIColor.systemYellow.image()
        onlinePresenceImage = UIColor.systemGreen.image()
        self.isProfileOfLoggedInUser = isProfileOfLoggedInUser
        personModel = userModel
        profileCardData = ProfileCardModel()
        configureTableData()
    }
    
    var isUserOnline: Bool {
        let onlineUsers = PresenceManager.shared.onlineUsers
        return onlineUsers.contains(personModel.email)
    }
    
    func getAboutString(for email:String, completion: @escaping SuccessCompletion) {
        DispatchQueue.background(background: {[weak self] in
            ProfileCardService.shared.fetchProfileCardData(for: self?.personModel.email ?? "") {[weak self] res in
                switch res {
                case .failure(_):
                    completion(false)
                    break
                case .success(let data):
                    self?.profileCardData = data
                    completion(true)
                }
            }
        })
    }
}

extension ProfileViewModel {
    private func configureTableData() {
        tableData.append(contentsOf: [
            .about, .phoneNumber, .secondaryEmail, .address
        ])
        if !isProfileOfLoggedInUser {
            tableData.append(.blockContact)
        }
    }
}
