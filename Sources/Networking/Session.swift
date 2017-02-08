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
    /// The boolean value indicates whether the loading has finished. If false, more items may be loaded and the
    /// completionHandler will be called again.
    ///
    /// - Parameters:
    ///     - result: The (partial) result.
    ///     - error: A resulting error
    ///     - finished: Indicates whether the loading has finished.
    public typealias IntermediateResultHandler<T> = (T?, SessionError?, Bool) -> Void

    /// The completion handler called when the request has been fullfilled or failed.
    ///
    /// - Parameters:
    ///     - result: The (partial) result.
    ///     - error: A resulting error
    public typealias ResultHandler<T> = (T?, SessionError?) -> Void

    private var token: Token {
        didSet {
            urlSession.configuration.httpAdditionalHeaders = httpHeaders
            resumeQueuedTasks()
        }
    }

    /// The authorization type which this session uses.
    public var authorizationType: Authorization {
        return token.authorizationType
    }

    /// The Reddit base url to which requests are made.
    let apiHost = URL(string: "https://oauth.reddit.com")!

    init(token: Token) {
        self.token = token
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
