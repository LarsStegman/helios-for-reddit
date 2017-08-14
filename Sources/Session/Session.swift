//
//  Session.swift
//  Helios
//
//  Created by Lars Stegman on 21-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class HELSession {

    /// The completion handler called when the request is successfull.
    ///
    /// - Parameters:
    ///     - result: The (partial) result.
    public typealias ResultHandler<T: Decodable> = (T) -> Void

    /// Called when a request has failed with an error indicating what went wrong.
    public typealias ErrorHandler = (SessionError) -> Void


    // MARK: - Authorization handling

    private var token: Token {
        didSet {
            urlSession.configuration.httpAdditionalHeaders = httpHeaders()
            resumeQueuedTasks()
        }
    }

    /// The authorization type which this session uses.
    public var sessionOwner: Authorization {
        return token.authorizationType
    }

    /// The Reddit base url to which requests are made.
    public var apiHost = URL(string: "https://oauth.reddit.com")!

    private var canMakeRequests: Bool {
        return !token.expired
    }

    private var willBeAbleToMakeRequest: Bool {
        return token.refreshable
    }

    init(token: Token) {
        self.token = token
    }
    
    /// The headers for the http requests.
    private func httpHeaders() -> [AnyHashable : Any] {
        return ["Authorization" : "bearer \(token.accessToken)",
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent" : Credentials.sharedInstance.userAgentString]
    }

    // MARK: - Task management

    /// The urlSession through which all the http requests for this session are routed.
    private(set) lazy var urlSession: URLSession = {
        var configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = httpHeaders()
        return URLSession(configuration: configuration)
    }()

    /// The queued tasks.
    private var queuedTasks: [URLSessionTask] = []

    /// Tasks added to the queue will be executed as soon as possible. Before the task is resumed
    /// the token is checked for validity. If the token has expired, it is refreshed and the added
    /// task is entered into a queue. Once the token is refreshed, the task will be executed.
    ///
    /// - Parameter task: The task to perform.
    private func queue(task: URLSessionTask) {
        guard !token.expired else {
            print("Task queued, expired: \(token.expired)")
            queuedTasks.append(task)
            // Refresh
            return
        }

        task.resume()
    }

    func queueTask<T: Decodable>(url: URL, result: @escaping ResultHandler<T>, error: @escaping ErrorHandler) {
        let task = urlSession.dataTask(with: url) { (data, response, taskError) in
            guard let data = data else {
                error(.noResult)
                return
            }
            do {
                let resultValue = try JSONDecoder().decode(T.self, from: data)
                result(resultValue)
            } catch let errorMessage {
                print(errorMessage)
                error(.noResult)
            }
        }

        queue(task: task)
    }

    /// Resume all queued tasks. If the token has expired, it will not execute the queued tasks.
    private func resumeQueuedTasks() {
        guard !token.expired else {
            // Refresh
            return
        }

        while !queuedTasks.isEmpty {
            queuedTasks.removeFirst().resume()
        }
    }

    // MARK: - Scope validation

    /// Check whether the token gives authorization for the provided scope
    ///
    /// - Parameter scope: The scope to check.
    /// - Returns: Whether the token gives authorization for the scope.
    public func authorized(for scope: Scope) -> Bool {
        return token.scopes.contains(scope)
    }

    func url(for endpoint: String) -> URL? {
        return URL(string: endpoint, relativeTo: apiHost)
    }
}
