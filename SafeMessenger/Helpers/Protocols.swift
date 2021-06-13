//
//  Protocols.swift
//  SafeMessenger
//
//  Created by Sandeep Kumar on 13/06/21.
//

import Foundation

// Doing this over Encodable as wanted something custom that doesn't throw randomly
protocol Serialisable {
    func serialisedObject() -> [String: Any]
}
