//
//  Token.swift
//  Helios
//
//  Created by Lars Stegman on 27-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

protocol Token {
    var accessToken: String { get }
    var scopes: [Scope] { get }
    var expiresAt: Date { get }

    var expired: Bool { get }
}

extension Token {
    var expired: Bool {
        return expiresAt < Date()
    }
}
