//
//  ApplicationOnlyAuthorizationProcessAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class ApplicationOnlyAuthorizationProcessAuthorizer: NSObject,
                                                            URLSessionTaskDelegate,
                                                            URLSessionDataDelegate {
    
    private lazy var urlSession: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }()
    private var retrieveAccessTokenTask: URLSessionDataTask?

    public func startAuthorization() {
        let request = ApplicationAuthorizationProcessComponents.makeAccessTokenURLRequest()
        retrieveAccessTokenTask = urlSession.dataTask(with: request)
        retrieveAccessTokenTask?.resume()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        if dataTask == retrieveAccessTokenTask {
            storeAccessToken(data: data)
        }
    }

    private func storeAccessToken(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
            failed(with: .redditError)
            return
        }
        TokenStore.makeApplicationToken(data: json) { [weak self] (token, error) in
            guard error == nil, let token = token else {
                switch error! {
                case .accessDenied: self?.failed(with: .accessDenied)
                case .invalidResponse: self?.failed(with: .redditError)
                default: self?.failed(with: .unknownError)
                }
                return
            }

            let storageSucceeded = TokenStore.saveToken(forAuthorizationType: .application, token: token)
            if storageSucceeded {
                self?.succeeded()
            } else {
                self?.failed(with: .internalError)
            }
        }
    }

    private func succeeded() {
        NotificationCenter.default.post(name: Notifications.finishedName, object: nil)
    }

    private func failed(with error: LoginAuthorizerError) {
        NotificationCenter.default.post(name: Notifications.failedName, object: error)
    }

    /// The notification names.
    public struct Notifications {
        /// The authorization has failed.
        public static let failedName = Notification.Name("failedApplicationAuthorizationNotification")

        /// The authorization has succeeded.
        public static let finishedName = Notification.Name("completedApplicationAuthorizationNotification")

        /// Should normally not be sent. Here for future proofing.
        public static let defaultName = Notification.Name("applicationAuthorizationNotification")
    }
}
