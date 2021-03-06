//
//  ChatListTableViewCell.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 11/06/21.
//

import Foundation
import UIKit

class ChatListTableViewCell: UITableViewCell {
    private let contentHeight: CGFloat = 80
    private lazy var defaultPresenceImage = UIColor.systemYellow.image()
    private lazy var onlinePresenceImage = UIColor.systemGreen.image()
    
    private lazy var chatTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19.5, weight: .regular)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lastMsg: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .light)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lastMsgTime: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .thin)
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var chatIcon: UIImageView = {
        let image = UIImage(named: Constants.ImageNameMemberPlaceholder)
        let imageView = UIImageView(image: image)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.label.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var presenceIcon: UIImageView = {
        let imageView = UIImageView(image: defaultPresenceImage)
        
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var constraintsNotActive = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(chatIcon)
        addSubview(chatTitle)
        addSubview(lastMsg)
        addSubview(lastMsgTime)
        addSubview(presenceIcon)
        
        NSLayoutConstraint.activate(staticConstraints())
    }
    
    override func prepareForReuse() {
        chatTitle.font = .systemFont(ofSize: 19.5, weight: .regular)
        lastMsg.font = .systemFont(ofSize: 15, weight: .light)
        lastMsgTime.font = .systemFont(ofSize: 13, weight: .thin)
        chatIcon.layer.borderColor = UIColor.label.cgColor
        chatIcon.layer.borderWidth = 0.5
        presenceIcon.image = defaultPresenceImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func staticConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        let imageSide = 0.15 * contentHeight
        let imageSize = contentHeight - (2 * imageSide)
        let presenceIconSize = 0.2 * imageSize
        let presenceIconSide = 0.069 * imageSize
        
        chatIcon.layer.cornerRadius = imageSize / 2.0
        presenceIcon.layer.cornerRadius = presenceIconSize / 2.0
        
        let chatTitleHeight = 0.40 * contentHeight
        let lastMsgHeight = 0.30 * contentHeight
        let msgTimeHeight = chatTitleHeight * 0.8
        let msgTimeWidth = width * 0.28
        
        constraints.append(contentsOf: [
            chatIcon.topAnchor.constraint(equalTo: topAnchor, constant: imageSide),
            chatIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: imageSide),
            chatIcon.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1 * imageSide),
            chatIcon.widthAnchor.constraint(equalToConstant: imageSize)
        ])
        
        constraints.append(contentsOf: [
            lastMsgTime.centerYAnchor.constraint(equalTo: chatTitle.centerYAnchor),
            lastMsgTime.heightAnchor.constraint(equalToConstant: msgTimeHeight),
            lastMsgTime.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * imageSide),
            lastMsgTime.widthAnchor.constraint(equalToConstant: msgTimeWidth)
        ])
        
        constraints.append(contentsOf: [
            chatTitle.topAnchor.constraint(equalTo: topAnchor, constant: imageSide),
            chatTitle.leadingAnchor.constraint(equalTo: chatIcon.trailingAnchor, constant: imageSide),
            chatTitle.heightAnchor.constraint(equalToConstant: chatTitleHeight),
            chatTitle.trailingAnchor.constraint(equalTo: lastMsgTime.leadingAnchor)
        ])
        
        constraints.append(contentsOf: [
            lastMsg.topAnchor.constraint(equalTo: chatTitle.bottomAnchor),
            lastMsg.leadingAnchor.constraint(equalTo: chatIcon.trailingAnchor, constant: imageSide),
            lastMsg.heightAnchor.constraint(equalToConstant: lastMsgHeight),
            lastMsg.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * imageSide)
        ])
        
        constraints.append(contentsOf: [
            presenceIcon.bottomAnchor.constraint(equalTo: chatIcon.bottomAnchor, constant: -1 * presenceIconSide),
            presenceIcon.trailingAnchor.constraint(equalTo: chatIcon.trailingAnchor, constant: -1 * presenceIconSide),
            presenceIcon.heightAnchor.constraint(equalToConstant: presenceIconSize),
            presenceIcon.widthAnchor.constraint(equalToConstant: presenceIconSize)
        ])
        
        return constraints
    }
}

extension ChatListTableViewCell {
    func configureCell(with model:ChatListTableViewCellViewModel) {
        chatTitle.text = model.getChatTitle()
        lastMsgTime.text = model.getLastMsgDateString()
        lastMsg.attributedText = model.getLastMessageAttributedText()
        model.updateImageView(for: chatIcon)
        
        updateElementsIfNotRead(with: model)
    }
    
    func updatePresenceIcon(isOnline: Bool) {
        if isOnline {
            presenceIcon.image = onlinePresenceImage
        }
        else {
            presenceIcon.image = defaultPresenceImage
        }
    }
    
    private func updateElementsIfNotRead(with model:ChatListTableViewCellViewModel) {
        guard model.shouldMarkUnread else {
            return
        }
        chatTitle.font = .systemFont(ofSize: 19.5, weight: .bold)
        lastMsg.font = .systemFont(ofSize: 15, weight: .bold)
        lastMsgTime.font = .systemFont(ofSize: 13, weight: .bold)
        chatIcon.layer.borderColor = UIColor.systemBlue.cgColor
        chatIcon.layer.borderWidth = 2
    }
}
