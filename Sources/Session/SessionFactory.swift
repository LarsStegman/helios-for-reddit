//
//  SessionFactory.swift
//  Helios
//
//  Created by Lars Stegman on 05-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class SessionFactory {
    private init() { }
    private static var decoder = PropertyListDecoder()

    /// Creates a session for the specified user name.
    ///
    /// - Parameter userName: The user name of the user
    /// - Returns: The session
    /// - Throws: Throws a `SessionError.unauthorized` error if the user is not authorized.
    public static func makeSession(authorization: Authorization) throws -> HELSession {
        guard let token = TokenStore.retrieveToken(for: authorization) else {
            throw SessionError.unauthorized
        }

        return HELSession(token: token)
    }

    public static func signout(authorization: Authorization) {
        TokenStore.revokeToken(for: authorization)
    }
}
