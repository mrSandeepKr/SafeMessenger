//
//  Utils.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 06/06/21.
//

import Foundation

class Utils {
    static let shared = Utils()
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        return formatter
    }()
    
    func getLoggedInUserEmail() -> String? {
        let email = (UserDefaults.standard.value(forKey: UserDefaultConstant.userEmail) ?? "") as! String
        return email
    }
    
    func getLoggedInUserSafeEmail() -> String? {
        guard let userEmail = getLoggedInUserEmail() else {
            return nil
        }
        return safeEmail(email: userEmail)
    }
    
    func safeEmail(email: String?) -> String? {
        guard let email = email else {
            print("Utils: no Email passed to safeEmail Converter")
            return nil
        }
        
        return email.replacingOccurrences(of: ".", with: "-")
    }
}
