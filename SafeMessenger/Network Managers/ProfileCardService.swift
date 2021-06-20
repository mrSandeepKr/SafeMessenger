//
//  ProfileCardService.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 20/06/21.
//

import Foundation
import FirebaseDatabase

enum ProfileCardServiceError: Error {
    case FailedToGetData
}

class ProfileCardService {
    static let shared = ProfileCardService()
    
    let database = Database.database(url: URLStrings.databaseURL).reference()
}

extension ProfileCardService {
    func fetchAboutString(for email:String, completion: @escaping ResultStringCompletion) {
        guard let safeEmail = Utils.shared.safeEmail(email: email) else {
            completion(.failure(ApiHandlerErrors.FailedSafeEmailGnrtn))
            return
        }
        let ref = database.child(getDBAboutStringPath(for: safeEmail))
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let aboutString = snapshot.value as? String,
                  !aboutString.isEmpty
            else {
                print("ApiHandler: Fetch About String Failed")
                completion(.failure(ApiHandlerErrors.FailedToGetAboutString))
                return
            }
            print("ApiHandler: Fetch About String Success")
            completion(.success(aboutString))
        }
    }
    
    func fetchProfileCardData(for email: String, completion: @escaping (Result<ProfileCardModel,Error>)-> Void) {
        guard let safeEmail = Utils.shared.safeEmail(email: email) else {
            return
        }
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String:Any]
            else {
                completion(.failure(ProfileCardServiceError.FailedToGetData))
                return
            }
            let data = ProfileCardModel(about: value[Constants.DbPathAboutString] as? String,
                                        address: value[Constants.DbPathAddress] as? String,
                                        number: value[Constants.DbPathPhoneNumer] as? String,
                                        secondaryEmail: value[Constants.DbPathSecondaryEmail] as? String)
            completion(.success(data))
        }
    }
    
    func setAboutString(info: String,  completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.getLoggedInUserSafeEmail() else {
            return
        }
        setProfileCardInfo(path: getDBAboutStringPath(for: safeEmail), info:info , completion: completion)
    }
    
    func setPhoneNumber(info: String,  completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.getLoggedInUserSafeEmail() else {
            return
        }
        setProfileCardInfo(path: getDBPhoneNumberPath(for: safeEmail), info: info, completion: completion)
    }
    
    func setSecondaryEmail(info: String,  completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.getLoggedInUserSafeEmail() else {
            return
        }
        setProfileCardInfo(path: getDBSecondaryEmailPath(for: safeEmail), info: info, completion: completion)
    }
    
    func setAddress(info: String,  completion: @escaping SuccessCompletion) {
        guard let safeEmail = Utils.shared.getLoggedInUserSafeEmail() else {
            return
        }
        setProfileCardInfo(path: getDBAddressPath(for: safeEmail), info: info, completion: completion)
    }
}

extension ProfileCardService {
    private func getDBAboutStringPath(for safeEmail: String) -> String{
        return "\(safeEmail)/\(Constants.DbPathAboutString)"
    }
    
    private func getDBPhoneNumberPath(for safeEmail: String) -> String{
        return "\(safeEmail)/\(Constants.DbPathPhoneNumer)"
    }
    
    private func getDBSecondaryEmailPath(for safeEmail: String) -> String{
        return "\(safeEmail)/\(Constants.DbPathSecondaryEmail)"
    }
    
    private func getDBAddressPath(for safeEmail: String) -> String{
        return "\(safeEmail)/\(Constants.DbPathAddress)"
    }
    
    private func setProfileCardInfo(path: String, info: String, completion: @escaping SuccessCompletion) {
        guard !path.isEmpty, !info.isEmpty
        else {
            completion(false)
            return
        }
        
        let ref = database.child(path)
        ref.setValue(info) { err, _ in
            guard err == nil else {
                completion(false)
                return
            }
            UserDefaults.standard.setValue(info, forKey: String(path.split(separator: "/")[1]))
            completion(true)
        }
    }
}
