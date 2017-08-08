//
//  Token.swift
//  Helios
//
//  Created by Lars Stegman on 27-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// A token that can be used for Reddit authorization.
protocol Token: Codable {

    /// The access token.
    var accessToken: String { get }

    /// The token that can be used to refresh this token.
    var refreshToken: String? { get }

    /// The list of scopes the token is valid for.
    var scopes: [Scope] { get }

    /// The expiration date of the token.
    var expiresAt: Date { get }

    var authorizationType: Authorization { get }

    var refreshable: Bool { get }
}

extension Token {
    /// Whether the token is expired.
    var expired: Bool {
        return expiresAt < Date()
    }
}
