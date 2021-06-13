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
typealias UploadPictureCompletion = (Result<String,Error>) -> Void
typealias CreateAccountCompletion = (String) -> Void
typealias FetchAllUsersCompletion = (Result<[ChatAppUserModel],Error>) -> Void
typealias FetchUserCompletion = (Result<ChatAppUserModel,Error>) -> Void
typealias CreateConversationCompletion = (Result<Bool,Error>) -> Void
