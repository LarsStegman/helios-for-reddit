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
    let scopes: [Scope]
    let expiresAt: Date
}

extension ApplicationToken {
    init?(json: [String: Any]) {
        guard let accessToken = json["access_token"] as? String,
            let scope = json["scope"] as? String,
            let expiresIn = json["expires_in"] as? TimeInterval else {
                return nil
        }
        let scopes = scope.components(separatedBy: " ").map({ return Scope(rawValue: $0)! })
        self = ApplicationToken(accessToken: accessToken, scopes: scopes,
                                expiresAt: Date(timeIntervalSinceNow: expiresIn))

    }
}
