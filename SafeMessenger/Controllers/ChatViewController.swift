//
//  ChatViewController.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 01/06/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    
    private let viewModel: ChatViewModel
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.background(background: {[weak self] in
            self?.viewModel.getUserInfoForChat {[weak self] success in
                guard let strongSelf = self else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.title = strongSelf.viewModel.memberModel?.firstName
                }
            }
            self?.viewModel.markLastMsgAsReadIfNeeded()
            self?.addObserverOnMessages()
        })
        
        setUpMessageKitStuff()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.removeMessagesObserver()
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return viewModel.selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            print("ChatViewController: Trying to send empty message")
            return
        }
        let isNewConvo = viewModel.isNewConversation
        viewModel.sendMessage(to: viewModel.memberEmail, msg: text) {[weak self] success in
            if success {
                print("ChatViewController: Message Send Success")
                if isNewConvo {
                    self?.addObserverOnMessages()
                }
            }
            else {
                print("ChatViewController: Message Send Failed")
            }
        }
    }
}

extension ChatViewController {
    private func updateViewForMessages() {
        messagesCollectionView.reloadData()
    }
    
    private func setUpMessageKitStuff() {
        messagesCollectionView.contentInset = UIEdgeInsets(top: 59, left: 0, bottom: 0, right: 0)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    private func addObserverOnMessages() {
        self.viewModel.getMessages(completion: { [weak self] success in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.updateViewForMessages()
            }
        })
    }
}
