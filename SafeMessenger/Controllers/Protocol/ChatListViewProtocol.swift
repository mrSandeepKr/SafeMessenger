//
//  ChatListViewProtocol.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 01/06/21.
//

import Foundation

protocol ChatListViewProtocol: AnyObject {
    func didSelectChatFromChatList(viewData: [String: Any])
}
