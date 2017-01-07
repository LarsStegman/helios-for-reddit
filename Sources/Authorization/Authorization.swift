//
//  Authorization.swift
//  Helios
//
//  Created by Lars Stegman on 27-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

struct Authorization {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let scopes: [Scope]
    let expiresAt: Date

    var expired: Bool {
        return expiresAt < Date()
    }
}
