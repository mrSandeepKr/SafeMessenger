//
//  Constants.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 24/05/21.
//

import Foundation

class URLStrings {
    static let databaseURL = "https://safemessenger-a70fb-default-rtdb.asia-southeast1.firebasedatabase.app/"
}

class Constants {
    static let firstName = "firstName"
    static let secondName = "secondName"
    static let email = "email"
    static let name = "name"
    static let unknownUser = "Unknown User"
    static let conversations = "conversations"
    static let users = "users"
    static let convoID = "convoID"
    static let sendDate = "sentDate"
    static let isRead = "isRead"
    static let msgContent = "msgContent"
    static let senderID = "senderID"
    static let displatName = "displayName"
    static let imageURL = "imageURL"
    static let messages = "messages"
    static let lastMessage = "lastMessage"
    static let members = "members"
    static let topic = "topic"
    static let convoType = "convoType"
    static let sender = "sender"
    static let messageID = "messageID"
    static let msgType = "msgType"
    
    static let ConvoTypeOneOnOne = "oneOnOne"
    static let ConvoTypeGroupChat = "groupChat"
    
    static let MessageTypeText = "text"
    
    static let ImageNamePersonPlaceholder = "personPlaceholder"
    static let ImageNameLogo = "logo"
    static let ImageNameGoogleIcon = "googleIcon"
    static let ImageNameMemberPlaceholder = "memberPlaceholder"
    static let ImageNameHamburgerBackgroud = "hamburgerBackground"
}

class UserDefaultConstant {
    static let isLoggedIn = "isLoggedIn"
    static let profileImageUrl = "profileImageUrl"
    static let userEmail = "email"
    static let userName = "name"
}
