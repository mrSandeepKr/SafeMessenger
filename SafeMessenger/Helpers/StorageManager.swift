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

public typealias UploadPictureCompletion = (Result<String,Error>) -> Void

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    private var userEmail: String {
        return UserDefaults.standard.value(forKey: UserDefaultConstant.userEmail) as! String
    }
    
    static func safeEmail(for email: String) -> String {
        return email.replacingOccurrences(of: ".", with: "-")
    }
    
    static func profileImageFilename(for safeEmail: String) -> String {
        return "\(safeEmail)_profile_image.png"
    }
    
    static func profileImageRefPath(fileName: String) -> String {
        return "images/\(fileName)"
    }
    
    static var profileImagePath : String {
        let email: String = UserDefaults.standard.value(forKey: UserDefaultConstant.userEmail) as! String
        let safeEmail = StorageManager.safeEmail(for: email)
        let fileName = StorageManager.profileImageFilename(for: safeEmail)
        let path = StorageManager.profileImageRefPath(fileName: fileName)
        return path
    }
}

extension StorageManager {
    /// Uploads picture to FirebaseStorage and returns Completion with Result of String
    public func uploadProfileImage(with data:Data, fileName: String, completion:@escaping UploadPictureCompletion) {
        let profileRef = storage.child(StorageManager.profileImageRefPath(fileName: fileName))
        profileRef.putData(data, metadata: nil) { metadata, err in
            guard err == nil else {
                print("StorageManager: Upload Profile Picture Failed")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            profileRef.downloadURL { url, err in
                guard err == nil, let url = url else {
                    completion(.failure(StorageError.failedToGetDownloadURL))
                    return
                }
                print("StorageManager: Upload Profile Picture Success")
                completion(.success(url.absoluteString))
            }
        }
    }
    
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
        downloadURL(for: path) { res in
            switch res {
            case .success(let url):
                URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, err in
                    guard err == nil, let data = data else {
                        return
                    }
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        imageView.image = image
                    }
                }.resume()
                break
            case .failure(_):
                break
            }
        }
            
        
    }
}
