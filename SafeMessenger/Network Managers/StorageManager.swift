//
//  StorageManager.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 04/06/21.
//

import Foundation
import FirebaseStorage

public enum StorageError: Error {
    case failedToUpload
    case failedToGetDownloadURL
}

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    static func safeEmail(for email: String) -> String {
        return email.replacingOccurrences(of: ".", with: "-")
    }
    
    static func profileImageFilename(for safeEmail: String) -> String {
        if safeEmail.isEmpty {
            return ""
        }
        return "\(safeEmail)\(Constants.ProfileImageSuffix)"
    }
    
    static func profileImageRefPath(fileName: String) -> String {
        if fileName.isEmpty {
            return ""
        }
        return "\(Constants.StoragePathImages)/\(fileName)"
    }
    
    static var profileImagePath : String {
        let email: String = Utils.shared.getLoggedInUserEmail() ?? ""
        let safeEmail = StorageManager.safeEmail(for: email)
        let fileName = StorageManager.profileImageFilename(for: safeEmail)
        let path = StorageManager.profileImageRefPath(fileName: fileName)
        return path
    }
    
    static func chatImagesPath(fileName: String) -> String {
        return "\(Constants.StoragePathChatImage)/\(fileName)"
    }
}

//MARK: Profile
extension StorageManager {
    /// Uploads picture to FirebaseStorage and returns Completion with Result of String
    public func uploadUserProfileImage(with data:Data, fileName: String, completion:@escaping ResultStringCompletion) {
        let profileImagePath = StorageManager.profileImageRefPath(fileName: fileName)
        uploadData(to: profileImagePath, data: data) { res in
            switch res {
            case .success(let downloadURL):
                print("StorageManager: Upload User Profile Image Success")
                completion(.success(downloadURL.absoluteString))
            case .failure(let err):
                print("StorageManager: Upload User Profile Image Failed - with \(err)")
                completion(.failure(err))
            }
        }
    }
}

//MARK: Chat Service fuctions
extension StorageManager {
    func uploadImageToMessageSection(filename: String, imageData: Data, completion:@escaping ResultStringCompletion) {
        let chatImagesPath = StorageManager.chatImagesPath(fileName: filename)
        uploadData(to: chatImagesPath, data: imageData) { res in
            switch res {
            case .success(let url):
                completion(.success(url.absoluteString))
                break
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}


//MARK: Utils
extension StorageManager {

    ///Pass in the path to get downloadURL and update the imageView Passed
    func downloadImageURLandUpdateView(for imageView: UIImageView?, path: String, completion:@escaping SuccessCompletion = {_ in}) {
        if path.isEmpty {
            return
        }
        
        getDownloadURL(for: path) { res in
            switch res {
            case .success(let url):
                DispatchQueue.main.async {
                        imageView!.sd_setImage(with: url, completed: nil)
                }
                completion(true)
                break
            case .failure(_):
                completion(false)
                break
            }
        }
    }
    
    ///Pass in the path to get downloadURL as Strintg
    func getDownloadURLString(for path: String, completion:@escaping ResultStringCompletion) {
        getDownloadURL(for: path) { res in
            switch res {
            case .success(let url):
                completion(.success(url.absoluteString))
                break
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
    
    ///Pass in the path to upload the data and get downloadURL
    private func uploadData(to path:String,data: Data, completion: @escaping ResultURLCompletion) {
        let ref = storage.child(path)
        ref.putData(data, metadata: nil) { metadata, err in
            guard err == nil else {
                completion(.failure(StorageError.failedToUpload))
                return
            }
            ref.downloadURL { url, err in
                guard err == nil, let url = url else {
                    completion(.failure(StorageError.failedToGetDownloadURL))
                    return
                }
                completion(.success(url))
            }
        }
    }
    
    ///Pass in the path to get the download URL
    private func getDownloadURL(for path: String, completion: @escaping ResultURLCompletion) {
        let ref = storage.child(path)
        ref.downloadURL { url, err in
            guard let url = url , err == nil else {
                completion(.failure(StorageError.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
}
