//
//  SettingsViewModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import Foundation
import UIKit

enum SettingsTableDataType {
    case phonenumber(String)
    case secondaryEmail(String)
    case address(String)
}

class SettingsViewModel {
    var tableData = [SettingsTableDataType]()
    
    init() {
        getUserSettingsData()
    }
}

extension SettingsViewModel {
    func getUserSettingsData() {
        var array: [SettingsTableDataType] = []
        array.append(.phonenumber(Utils.shared.getLoggedInUserPhoneNum() ?? "No Num added"))
        array.append(.secondaryEmail(Utils.shared.getLoggedInUserSecondaryEmail() ?? "No Seconday email added"))
        array.append(.address(Utils.shared.getLoggedInUserAddress() ?? "No Address added"))
        
        tableData = array
    }
    
    func getAlert(for data: SettingsTableDataType, completion: @escaping SuccessCompletion) -> UIAlertController {
        let (title,msg) = getAlertStrings(for: data)
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addTextField { _ in
            
        }
        alert.addAction(UIAlertAction(title: "Cancel",style: .destructive))
        
        switch data {
        case .address(_):
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                guard let text = alert.textFields?.first?.text,
                      !text.isEmpty
                else {
                    return
                }
                ProfileCardService.shared.setAddress(info: text, completion: completion)
            }))
        case .phonenumber(_):
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                guard let text = alert.textFields?.first?.text,
                      !text.isEmpty
                else {
                    return
                }
                ProfileCardService.shared.setPhoneNumber(info: text, completion: completion)
            }))
        case .secondaryEmail(_):
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { _ in
                guard let text = alert.textFields?.first?.text,
                      !text.isEmpty, text.isValidEmail()
                else {
                    return
                }
                ProfileCardService.shared.setSecondaryEmail(info: text, completion: completion)
            }))
        }
        return alert
    }
    
    private func getAlertStrings(for data: SettingsTableDataType) -> (String, String) {
        var title = "",msg = ""
        switch  data {
        case .address(_):
            title = "Update Address"
            msg = "Enter the Address it will be visible to people viewing your profile"
        case .phonenumber(_):
            title = "Update Phone Numer"
            msg = "Enter the Phone Number it will be visible to people viewing your profile"
        case .secondaryEmail(_):
            title = "Update secondary Email"
            msg = "Enter the Secondary it will be visible to people viewing your profile"
        }
        return (title,msg)
    }
}
