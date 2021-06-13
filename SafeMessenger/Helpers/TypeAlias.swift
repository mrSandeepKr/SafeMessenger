//
//  TypeAlias.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

typealias UsersList = [[String: Any]]
typealias User = [String: Any]
typealias UploadPictureCompletion = (Result<String,Error>) -> Void
typealias CreateAccountCompletion = (String) -> Void
typealias FetchAllUsersCompletion = (Result<UsersList,Error>) -> Void
typealias CreateConversationCompletion = (Result<Bool,Error>) -> Void
