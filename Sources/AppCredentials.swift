//
//  AppCredentials.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol AppCredentials {
    var clientId: String { get }
    var redirectUri: URL { get }
    var authorizationDuration: AuthorizationDuration { get }
    var authorizationScopes: [Scope] { get }
}
