//
//  MediaModel.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 15/06/21.
//

import Foundation
import MessageKit

struct MediaModel: MediaItem, Serialisable {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage = UIImage.checkmark
    var size: CGSize = CGSize(width: 200, height: 200)
    
    func serialisedObject() -> [String : Any] {
        guard let url = url else {
            return [:]
        }
        
        return [
            Constants.url: url.absoluteString
        ]
    }
}
