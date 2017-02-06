//
//  Token.swift
//  Helios
//
//  Created by Lars Stegman on 27-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// A token that can be used for Reddit authorization.
protocol Token {

    /// The access token.
    var accessToken: String { get }

    /// The list of scopes the token is valid for.
    var scopes: [Scope] { get }

    /// The expiration date of the token.
    var expiresAt: Date { get }

    /// A data representation of the token.
    var data: Data { get }

    var authorizationType: Authorization { get }

    /// Initialize the token from a data object.
    init?(from data: Data)
}

extension Token {
    /// Whether the token is expired.
    var expired: Bool {
        return expiresAt < Date()
    }
}
