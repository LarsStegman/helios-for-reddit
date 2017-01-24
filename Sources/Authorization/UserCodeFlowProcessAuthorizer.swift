//
//  UserCodeFlowProcessAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// Handles the Code Flow Authorization process for a user which wants to authorize the application.
public class UserCodeFlowProcessAuthorizer: NSObject,
                                            URLSessionTaskDelegate, URLSessionDataDelegate {

    public static let sharedInstance = UserCodeFlowProcessAuthorizer()
    public var compactAuthorizationPage = false {
        didSet {
            pageLoader.compact = compactAuthorizationPage
        }
    }

    // MARK: - Composed elements.
    private let pageLoader = AuthorizationPageLoader(flowType: .code)
    private lazy var urlSession: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    private var retrieveAccessTokenTask: URLSessionDataTask?

    private var newState: String {
        return "GaiaAuthorization-\(Credentials.sharedInstance.appName)-" +
            "\(Date().timeIntervalSince1970)"
    }
    private var lastState: String?

    /// Starts the authorization process by providing a url for the user to visit. On the visited 
    /// page, the user can authorize or deny authorization.
    ///
    /// - Returns: The Reddit page on which the user can grant or deny access.
    public func startAuthorization() -> URL? {
        let state = newState
        lastState = state
        do {
            return try pageLoader.pageForAuthorization(state: state)
        } catch AuthorizationError.invalidStateString {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
        } catch {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.unknownError)
        }
        lastState = nil
        return nil
    }

    /// Call when the user has granted or denied authorization. The url should be the redirect url 
    /// of your application including the parameters Reddit has filled in.
    ///
    /// - Parameter url: The redirect url containing the parameters.
    public func handleRedditRedirectCallback(_ url: URL) {
        guard let lastState = lastState else {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard components?.host == Credentials.sharedInstance.redirectUri.host,
            let parameters = components?.queryItems,
            !parameters.isEmpty else {
            failed(with: LoginAuthorizerError.redditError)
            return
        }

        do {
            let code = try CodeFlowAuthorizationProcessComponents
                .extractCode(callbackURIParameters: parameters, sentState: lastState)
            let request = CodeFlowAuthorizationProcessComponents
                .makeAccessTokenURLRequest(credentials: Credentials.sharedInstance, receivedCode: code)
            retrieveAccessTokenTask = urlSession.dataTask(with: request)
            retrieveAccessTokenTask?.resume()
        } catch let error as AuthorizationError
            where [AuthorizationError.unsupportedResponseType, .invalidScope,
                   .invalidRequest].contains(error) {
            failed(with: .internalError)
        } catch let error as AuthorizationError where error == .accessDenied {
            failed(with: .accessDenied)
        } catch let error {
            NSLog("Helios - Authorization failed with %s", error.localizedDescription)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        if dataTask == retrieveAccessTokenTask {
            do {
                try parseAccessToken(data: data)
            } catch AuthorizationError.invalidResponse {
                failed(with: .redditError)
            } catch AuthorizationError.genericRedditError(code: _, message: _) {
                failed(with: .redditError)
            } catch let error as AuthorizationError
                where [.unsupportedGrantType, .noCode, .invalidGrantValue].contains(error) {
                failed(with: .internalError)
            } catch {
                failed(with: .unknownError)
            }
        }
    }

    /// Parses access token data Reddit has provided
    ///
    /// - Parameter data: A json object containing user token
    /// - Throws: Make sure the data is a json [String: Any] object.
    private func parseAccessToken(data: Data) throws {
        guard let json = (try? JSONSerialization.jsonObject(with: data))
            as? [String: Any] else {
                throw AuthorizationError.invalidResponse
        }
        TokenStore.makeUserToken(data: json) { [weak self] (token, error) in
            guard error == nil, let token = token else {
                switch error! {
                case .invalidResponse, .unableToRetrieveUserName: self?.failed(with: .redditError)
                case .accessDenied: self?.failed(with: .accessDenied)
                default: self?.failed(with: .unknownError)
                }
                return
            }

            self?.finishParsingAccessToken(token: token)
        }
    }

    /// Finalizes the parsing process. Stores the token in secure storage.
    ///
    /// - Parameter token: The token to store
    private func finishParsingAccessToken(token: UserToken) {
        if let name = token.userName {
            let success = TokenStore.saveToken(forAuthorizationType: .user(name: name),
                                               token: token)
            if success {
                succeeded(user: name)
            } else {
                failed(with: .internalError)
            }
        } else {
            failed(with: .internalError)
        }
    }

    /// Authorization succeeded.
    ///
    /// - Parameter user: The username of the authorized user
    private func succeeded(user: String) {
        lastState = nil
        retrieveAccessTokenTask = nil
        print("Authorized \(user)!")
        NotificationCenter.default
            .post(name: LoginAuthorizerNotifications.finishedAuthorizationName, object: user)
    }

    /// Authorization failed
    ///
    /// - Parameter error: The error which caused the failure.
    private func failed(with error: LoginAuthorizerError) {
        lastState = nil
        retrieveAccessTokenTask = nil
        print("Failed with error: \(error.localizedDescription)")
        NotificationCenter.default
            .post(name: LoginAuthorizerNotifications.failedAuthorizationName, object: error)
    }

    /// The notification names.
    public struct LoginAuthorizerNotifications {
        /// The authorization has failed.
        public static let failedAuthorizationName = Notification.Name("failedLoginNotification")

        /// The authorization has succeeded.
        public static let finishedAuthorizationName = Notification.Name("completedLoginNotification")

        /// Should normally not be sent. Here for future proofing.
        public static let defaultName = Notification.Name("loginAuthorizerNotification")
    }
}
