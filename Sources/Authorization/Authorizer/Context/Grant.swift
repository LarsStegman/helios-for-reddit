//
//  Grant.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

enum GrantType: String {
    case authorizationCode = "authorization_code"
    case refreshToken = "refresh_token"
    case installedClient = "https://oauth.reddit.com/grants/installed_client"
    case clientCredentials = "client_credentials"
}
