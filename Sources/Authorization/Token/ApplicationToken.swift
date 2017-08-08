//
//  ApplicationToken.swift
//  Helios
//
//  Created by Lars Stegman on 13-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct ApplicationToken: Token {
    let accessToken: String
    let refreshToken: String? = nil
    let scopes = [Scope.read]
    let expiresAt: Date
    let authorizationType = Authorization.application
    let refreshable = false

    init(accessToken: String, expiresAt: Date) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
    }
}
