//
//  Session.swift
//  Helios
//
//  Created by Lars Stegman on 21-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class Session {
    private var token: Token
    private let credentials: Credentials

    init(token: Token) throws {
        guard let credentials = Credentials.sharedInstance else {
            throw SessionErrors.missingApplicationCredentials
        }

        self.token = token
        self.credentials = credentials
    }

    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")

        return request
    }

    private static func makeSession(userName: String?, tokenCreator: (Data) -> Token?)
            throws -> Session {
        let authorizationType: TokenStore.AuthorizationType
        if let name = userName {
            authorizationType = .user(name: name)
        } else {
            authorizationType = .application
        }

        guard let tokenData = TokenStore.retrieveTokenData(forAuthorizationType: authorizationType),
            let token = tokenCreator(tokenData) else {
                throw SessionErrors.unauthorized
        }

        return try Session(token: token)
    }

    public static func makeUserSession(userName: String) throws -> Session {
        return try makeSession(userName: userName, tokenCreator: { return UserToken(from: $0) })
    }

    public static func makeApplicationSession() throws -> Session {
        return try makeSession(userName: nil, tokenCreator: { return ApplicationToken(from: $0) })
    }
}

public enum SessionErrors: Error {
    case unauthorized
    case missingApplicationCredentials
}
