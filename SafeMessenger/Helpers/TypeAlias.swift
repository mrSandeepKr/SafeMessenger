//
//  TypeAlias.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 05/06/21.
//

import Foundation

typealias UsersList = [[String: String]]
typealias User = [String: String]
typealias UploadPictureCompletion = (Result<String,Error>) -> Void
typealias CreateAccountCompletion = (String) -> Void
typealias FetchAllUsersCompletion = (Result<UsersList,Error>) -> Void
