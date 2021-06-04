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
    
    /// Uploads picture to FirebaseStorage and returns Completion with Result of String
    public func uploadProfileImage(with data:Data, fileName: String, completion:@escaping UploadPictureCompletion) {
        let profileRef = storage.child("images/\(fileName)")
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
}
