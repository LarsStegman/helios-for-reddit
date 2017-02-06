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

    private static func makeSession(authorization: Authorization,
                                    tokenCreator: (Data) -> Token?) throws -> Session {
        guard let tokenData = TokenStore.retrieveTokenData(forAuthorizationType: authorization),
            let token = tokenCreator(tokenData) else {
                throw SessionError.unauthorized
        }

        return Session(token: token)
    }

    /// Creates a session for the specified user name.
    ///
    /// - Parameter userName: The user name of the user
    /// - Returns: The session
    /// - Throws: Throws a `SessionError.unauthorized` error if the user is not authorized.
    public static func makeUserSession(userName: String) throws -> Session {
        guard let tokenData = TokenStore.retrieveTokenData(forAuthorizationType: .user(name: userName)),
            let token = UserToken(from: tokenData) else {
            throw SessionError.unauthorized
        }

        return Session(token: token)
    }

    private static var appAuthorizer = ApplicationOnlyAuthorizationProcessAuthorizer()


    /// Creates an application session. If there is no application authorization present yet, an authorization will be 
    /// created.
    ///
    /// - Parameter completionHandler: Called with the session object, or an error.
    public static func makeApplicationSession(completionHandler:
                                                @escaping (Session?, SessionError?) -> Void) {
        if let tokenData = TokenStore.retrieveTokenData(forAuthorizationType: .application),
            let appToken = ApplicationToken(from: tokenData) {
            completionHandler(Session(token: appToken), nil)
        } else {
            NotificationCenter.default
                .addObserver(forName: ApplicationOnlyAuthorizationProcessAuthorizer.Notifications.finishedName,
                             object: appAuthorizer,
                             queue: nil) { (_) in
                if let tokenData = TokenStore.retrieveTokenData(forAuthorizationType: .application),
                    let token = ApplicationToken(from: tokenData) {
                    completionHandler(Session(token: token), nil)
                } else {
                    completionHandler(nil, .noResult)
                }
            }

            NotificationCenter.default
                .addObserver(forName: ApplicationOnlyAuthorizationProcessAuthorizer.Notifications.failedName,
                             object: appAuthorizer,
                             queue: nil) { (notification) in
                if let error = notification.object as? LoginAuthorizerError {
                    switch error {
                    case .accessDenied: completionHandler(nil, .unauthorized)
                    case .redditError: completionHandler(nil, .invalidResponse)
                    case .internalError, .unknownError: completionHandler(nil, .noResult)
                    }
                } else {
                    completionHandler(nil, .noResult)
                }
            }
            appAuthorizer.startAuthorization()
        }

    }
}
