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
        return "\(safeEmail)_profile_image.png"
    }
    
    static func profileImageRefPath(fileName: String) -> String {
        if fileName.isEmpty {
            return ""
        }
        return "images/\(fileName)"
    }
    
    static var profileImagePath : String {
        let email: String = Utils.shared.getLoggedInUserEmail() ?? ""
        let safeEmail = StorageManager.safeEmail(for: email)
        let fileName = StorageManager.profileImageFilename(for: safeEmail)
        let path = StorageManager.profileImageRefPath(fileName: fileName)
        return path
    }
}

extension StorageManager {
    /// Uploads picture to FirebaseStorage and returns Completion with Result of String
    public func uploadUserProfileImage(with data:Data, fileName: String, completion:@escaping UploadPictureCompletion) {
        let profileRef = storage.child(StorageManager.profileImageRefPath(fileName: fileName))
        profileRef.putData(data, metadata: nil) { metadata, err in
            guard err == nil else {
                print("StorageManager: Upload Profile Picture Failed")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            profileRef.downloadURL { url, err in
                guard err == nil, let url = url else {
                    print("StorageManager: Upload Profile Picture Failed with \(String(describing: err))")
                    completion(.failure(StorageError.failedToGetDownloadURL))
                    return
                }
                print("StorageManager: Upload Profile Picture Success")
                completion(.success(url.absoluteString))
            }
        }
    }
    
    ///Pass in the path of the userinfo to get the download URL
    public func downloadURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void) {
        let ref = storage.child(path)
        ref.downloadURL { url, err in
            guard let url = url , err == nil else {
                completion(.failure(StorageError.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    public func downloadImageURLandUpdateView(for imageView: UIImageView, path: String ) {
        if path.isEmpty {
            return
        }
        
        downloadURL(for: path) { res in
            switch res {
            case .success(let url):
                print("StorageManager: download Url Success")
                DispatchQueue.main.async {
                    imageView.sd_setImage(with: url, completed: nil)
                }
                break
            case .failure(_):
                print("StorageManager: download Url Failed")
                break
            }
        }
    }
}
