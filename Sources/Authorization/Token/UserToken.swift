//
//  UserToken.swift
//  Helios
//
//  Created by Lars Stegman on 13-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct UserToken: Token {
    let username: String?
    let accessToken: String
    let refreshToken: String?
    let scopes: [Scope]
    let expiresAt: Date

    var authorizationType: Authorization {
        if let name = username {
            return .user(name: name)
        } else {
            return .application
        }
    }
    var refreshable: Bool {
        return refreshToken != nil
    }

    init(username: String?, accessToken: String, refreshToken: String?, scopes: [Scope],
         expiresAt: Date) {
        self.username = username
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.scopes = scopes
        self.expiresAt = expiresAt
    }

    init(username: String?, token: UserToken) {
        self.init(username: username, accessToken: token.accessToken, refreshToken: token.refreshToken,
                         scopes: token.scopes, expiresAt: token.expiresAt)
    }

    private enum CodingKeys: String, CodingKey {
        case username
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case scopes = "scope"
        case expiresAt
        case expiresIn = "expires_in"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(scopes, forKey: .scopes)
        try container.encode(expiresAt, forKey: .expiresAt)
    }

    init(from: Decoder) throws {
        let container = try from.container(keyedBy: CodingKeys.self)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        if let scopesFromList = try? container.decode([Scope].self, forKey: .scopes) {
            scopes = scopesFromList
        } else {
            scopes = Scope.scopes(from: try container.decode(String.self, forKey: .scopes))
        }

        if let expirationDate = try? container.decode(Date.self, forKey: .expiresAt) {
            expiresAt = expirationDate
        } else {
            expiresAt = Date(timeIntervalSinceNow: try container.decode(TimeInterval.self, forKey: .expiresIn))
        }
    }
}

