//
//  UserToken.swift
//  Helios
//
//  Created by Lars Stegman on 13-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct UserToken: Token {
    let userName: String?
    let accessToken: String
    let refreshToken: String?
    let scopes: [Scope]
    let expiresAt: Date
}

extension UserToken {
    init?(userName: String?, json: [String: Any]) {
        guard let token = json["access_token"] as? String,
            let refreshToken = json["refresh_token"] as? String?,
            let scope = json["scope"] as? String,
            let expiresIn = json["expires_in"] as? TimeInterval else {
                return nil
        }

        let scopes = scope.components(separatedBy: " ").map({ return Scope(rawValue: $0)! })
        self = UserToken(userName: userName, accessToken: token, refreshToken: refreshToken,
                         scopes: scopes, expiresAt: Date(timeIntervalSinceNow: expiresIn))
    }
}
