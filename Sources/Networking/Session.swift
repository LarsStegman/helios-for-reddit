//
//  Session.swift
//  Helios
//
//  Created by Lars Stegman on 21-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class Session {

    /// The completion handler called when the request has been fullfilled or failed.
    /// The boolean value indicates whether the loading has finished.
    /// - T: The (partial) result.
    /// - SessionError: A resulting error
    /// - Bool: Indicates whether the loading has finished.
    public typealias ResultHandler<T> = (T?, SessionError?, Bool) -> Void

    private var token: Token {
        didSet {
            urlSession.configuration.httpAdditionalHeaders = httpHeaders
            resumeQueuedTasks()
        }
    }

    /// The authorization type which this session uses.
    public var authorizationType: TokenStore.AuthorizationType {
        return token.authorizationType
    }

    /// The Reddit base url to which requests are made.
    let apiHost = URL(string: "https://oauth.reddit.com")!

    private init(token: Token) {
        self.token = token
    }

    // MARK: - Session factory methods

    /// Creates a session
    ///
    /// - Parameters:
    ///   - userName: <#userName description#>
    ///   - tokenCreator: <#tokenCreator description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    private static func makeSession(authorization: TokenStore.AuthorizationType,
                                    tokenCreator: (Data) -> Token?)
            throws -> Session {
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
        return try makeSession(authorization: .user(name: userName),
                               tokenCreator: { return UserToken(from: $0) })
    }

    /// Creates a session for the application.
    ///
    /// - Returns: The session
    /// - Throws: Throws a `SessionError.unauthorized` error if the application is not authorized.
    public static func makeApplicationSession() throws -> Session {
        return try makeSession(authorization: .application,
                               tokenCreator: { return ApplicationToken(from: $0) })
    }

    // MARK: - Session management
    
    /// The headers for the http requests.
    private var httpHeaders: [AnyHashable : Any]? {
        return ["Authorization" : "bearer \(token.accessToken)",
                "User-Agent" : Credentials.sharedInstance.userAgentString]
    }

    /// The urlSession through which all the http requests for this session are routed.
    private(set) lazy var urlSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = self.httpHeaders
        return URLSession(configuration: configuration)
    }()

    /// The queued tasks.
    private var queuedTasks: [URLSessionTask] = []

    /// Tasks added to the queue will be executed as soon as possible. Before the task is resumed
    /// the token is checked for validity. If the token has expired, it is refreshed and the added
    /// task is entered into a queue. Once the token is refreshed, the task will be executed.
    ///
    /// - Parameter task: The task to perform.
    func queue(task: URLSessionTask) {
        guard !token.expired else {
            queuedTasks.append(task)
            return
        }

        task.resume()
    }

    /// Execute all queued tasks. If the token has expired, it will not execute the queued tasks.
    private func resumeQueuedTasks() {
        guard !token.expired else {
            return
        }

        while !queuedTasks.isEmpty {
            queuedTasks.removeFirst().resume()
        }
    }

    /// Check whether the token gives authorization for the provided scope
    ///
    /// - Parameter scope: The scope to check.
    /// - Returns: Whether the token gives authorization for the scope.
    func authorized(for scope: Scope) -> Bool {
        return token.scopes.contains(scope)
    }
}

public enum SessionError: Error {
    case unauthorized
    case missingScopeAuthorization(Scope)
    case invalidResponse
    case noResult
    case invalidSource
}
