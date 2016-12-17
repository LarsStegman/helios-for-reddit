//
//  AppCredentials.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public struct AppCredentials {
    let clientId: String
    let redirectUri: URL
    let authorizationDuration: AuthorizationDuration
    var authorizationScopes: [Scope]
    var secret: String = ""
}
