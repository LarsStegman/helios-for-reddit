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
    typealias ResultHandler<T> = (T?, SessionError?) -> Void

    private var token: Token {
        didSet {
            urlSession.configuration.httpAdditionalHeaders = httpHeaders
            resumeQueuedTasks()
        }
    }
    public var authorizationType: TokenStore.AuthorizationType {
        return token.authorizationType
    }
    private let credentials: Credentials
    let apiHost = URL(string: "https://oauth.reddit.com")!

    private init(token: Token) {
        self.token = token
        self.credentials = Credentials.sharedInstance
    }

    // MARK: - Session factory methods

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
                throw SessionError.unauthorized
        }

        return Session(token: token)
    }

    public static func makeUserSession(userName: String) throws -> Session {
        return try makeSession(userName: userName, tokenCreator: { return UserToken(from: $0) })
    }

    public static func makeApplicationSession() throws -> Session {
        return try makeSession(userName: nil, tokenCreator: { return ApplicationToken(from: $0) })
    }

    // MARK: - Session management
    
    /// The headers for the http requests.
    private var httpHeaders: [AnyHashable : Any]? {
        return ["Authorization" : "bearer \(token.accessToken)",
                "User-Agent" : self.credentials.userAgentString]
    }

    /// The urlSession through which all the http requests for this session are routed.
    private(set) lazy var urlSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = self.httpHeaders
        return URLSession(configuration: configuration)
    }()

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
