//
//  ChatViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 01/06/21.
//

import UIKit
import MessageKit



class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    
    private let selfSender = Sender(imageURL: "",
                                    senderId: "1",
                                    displayName: "Joe Smith")
//MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
