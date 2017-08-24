//
//  Session.swift
//  Helios
//
//  Created by Lars Stegman on 21-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class HELSession: TokenRefreshingDelegate {

    /// The completion handler called when the request is successfull.
    ///
    /// - Parameters:
    ///     - result: The (partial) result.
    public typealias ResultHandler<T: Decodable> = (T) -> Void

    /// Called when a request has failed with an error indicating what went wrong.
    public typealias ErrorHandler = (SessionError) -> Void


    // MARK: - Authorization handling

    fileprivate var token: Token {
        didSet {
            setupUrlSession()
        }
    }

    /// The authorization type which this session uses.
    public var sessionOwner: Authorization {
        return token.authorizationType
    }

    /// The Reddit base url to which requests are made.
    public var apiHost = URL(string: "https://oauth.reddit.com")!

    init(token: Token) {
        self.token = token
        setupUrlSession()
    }

    /// The urlSession through which all the http requests for this session are routed.
    private var urlSession: URLSession!

    private func setupUrlSession() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = httpHeaders()
        urlSession = URLSession(configuration: configuration)
    }

    /// The headers for the http requests.
    private func httpHeaders() -> [AnyHashable : Any] {
        return ["Authorization" : "bearer \(token.accessToken)",
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent" : Credentials.sharedInstance.userAgentString]
    }

    // MARK: - Task management

    /// The queued tasks.
    private var queuedTasks: [URLTask] = [] {
        didSet {
            print("Changed queuedTasks from \(oldValue) to \(queuedTasks)")
        }
    }

    /// Tasks added to the queue will be executed as soon as possible. Before the task is resumed
    /// the token is checked for validity. If the token has expired, it is refreshed and the added
    /// task is entered into a queue. Once the token is refreshed, the task will be executed.
    ///
    /// - Parameters:
    ///   - url: The url to make the request to
    ///   - result: Called when a result has been received
    ///   - error: Called when something went wrong while executing the task.
    func queueTask<T: Decodable>(url: URL, result: @escaping ResultHandler<T>, error: @escaping ErrorHandler) {
        let task: URLTask = (url, { (data, response, taskError) in
            guard let data = data else {
                error(.noResult)
                return
            }

            do {
                let resultValue = try JSONDecoder().decode(T.self, from: data)
                result(resultValue)
            } catch _ {
                if let redditError = try? JSONDecoder().decode(ApiError.self, from: data) {
                    error(redditError.sessionError ?? .apiError(redditError))
                } else {
                    error(.noResult)
                }

            }
        })

        queue(task: task)
    }

    /// Queues a task for execution. If a task cannot be executed yet, it is queued for later execution. If it will
    /// never be possible to perform the task, it will be canceled.
    ///
    /// - Parameter task: The task to queue.
    private func queue(task: URLTask) {
        let urlSessionTask = urlSession.dataTask(from: task)
        guard canMakeRequests else {
            if willBeAbleToMakeRequest {
                queuedTasks.append(task)
                reallowRequests()
            } else {
                urlSessionTask.cancel()
            }

            return
        }

        urlSessionTask.resume()
    }

    /// Resume all queued tasks. If the token has expired, it will not execute the queued tasks.
    private func resumeTasks() {
        guard canMakeRequests else {
            return
        }

        while !queuedTasks.isEmpty {
            let queuedTask = queuedTasks.removeFirst()
            urlSession.dataTask(from: queuedTask).resume()
        }
    }

    private func flushTasks() {
        while !queuedTasks.isEmpty {
            let queuedTask = queuedTasks.removeLast()
            urlSession.dataTask(from: queuedTask).cancel()
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

    // MARK: - Token refreshing

    /// Indicates whether requests can be made at the moment.
    private var canMakeRequests: Bool {
        return !token.expired
    }

    /// Indicates whether requests will be able to be made in the future.
    private var willBeAbleToMakeRequest: Bool {
        return token.refreshable
    }

    /// Whether we are working on reallowing the requests.
    private var reallowing = false

    /// Attempts to resolve problems preventing the making of requests.
    private func reallowRequests() {
        guard !reallowing else {
            return
        }

        reallowing = true
        if token.expired {
            token.refresh(delegate: self)
            return
        }
        reallowing = false
    }

    func tokenRefreshing(didRefresh token: Token, with newToken: Token) {
        self.token = newToken
        resumeTasks()
        reallowing = false
    }

    func tokenRefreshing(failedToRefresh token: Token) {
        flushTasks()
        reallowing = false
    }
}

fileprivate typealias URLTask = (url: URL, completion: (Data?, URLResponse?, Error?) -> Void)

fileprivate extension URLSession {
    func dataTask(from: URLTask) -> URLSessionDataTask {
        return self.dataTask(with: from.url, completionHandler: from.completion)
    }
}
