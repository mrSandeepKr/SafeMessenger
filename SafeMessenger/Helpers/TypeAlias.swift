//
//  TypeAlias.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

typealias UserDict = [String: Any]
typealias MessageDict = [String: Any]
typealias UsersDictList = [UserDict]

typealias FetchAllUsersCompletion = (Result<[ChatAppUserModel],Error>) -> Void
typealias FetchUserCompletion = (Result<ChatAppUserModel,Error>) -> Void
typealias FetchAllConversationsCompletion = (Result<[ConversationObject], Error>) -> Void
typealias FetchConversationThreadCompletion = (Result<ConversationThread, Error>) -> Void
typealias SendMessageCompletion = (_ success: Bool ,_ isNewConvo: Bool)-> Void

typealias ResultStringCompletion = (Result<String,Error>) -> Void
typealias StringCompletion = (String) -> Void
typealias SuccessCompletion = (Bool)-> Void
typealias ResultURLCompletion = (Result<URL,Error>) -> Void
typealias ResultBoolCompletion = (Result<Bool,Error>) -> Void
