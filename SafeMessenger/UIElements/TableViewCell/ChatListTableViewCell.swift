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
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.label.cgColor
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
        
        NSLayoutConstraint.activate(staticConstraints())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func staticConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        let imageSide = 0.15 * contentHeight
        let imageSize = contentHeight - (2 * imageSide)
        chatIcon.layer.cornerRadius = imageSize / 2.0
        
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
            chatTitle.trailingAnchor.constraint(equalTo: lastMsgTime.trailingAnchor)
        ])
        
        constraints.append(contentsOf: [
            lastMsg.topAnchor.constraint(equalTo: chatTitle.bottomAnchor),
            lastMsg.leadingAnchor.constraint(equalTo: chatIcon.trailingAnchor, constant: imageSide),
            lastMsg.heightAnchor.constraint(equalToConstant: lastMsgHeight),
            lastMsg.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * imageSide)
        ])
        
        return constraints
    }
}

extension ChatListTableViewCell {
    func configureCell(with model:ChatListTableViewCellViewModel) {
        chatTitle.text = model.getChatTitle()
        lastMsgTime.text = model.getLastMsgDateString()
        lastMsg.text = model.getLastMessageText()
        model.updateImageView(for: chatIcon)
    }
}
