//
//  AppCredentials.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// Something that describes the information about your app.
public protocol AppCredentials {
    /// The id that Reddit has generated for your app.
    var clientId: String { get }

    /// The redirect uri you have given Reddit
    var redirectUri: URL { get }

    /// How long you want to be authorized.
    var authorizationDuration: AuthorizationDuration { get }

    /// For what scopes you want to be authorized
    var authorizationScopes: [Scope] { get }

    /// The secret of your app, only applicable if you're running a script.
    var secret: String? { get }

    /// The user agent you want to use. It's recommended you set this by Reddit because they might
    /// think you're a bot that's spamming them if you don't.
    var userAgentString: String { get }
}
