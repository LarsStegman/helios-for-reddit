//
//  OAuthManager.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// Handles the Code Flow Authorization process for a user which wants to authorize the application.
class UserCodeFlowProcessAuthorizer: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {

    public static let sharedInstance = UserCodeFlowProcessAuthorizer()
    public var compactAuthorizationPage = false {
        didSet {
            pageLoader.compact = compactAuthorizationPage
        }
    }

    // Composed elements.
    private let pageLoader = AuthorizationPageLoader(flowType: .code)
    private lazy var urlSession: URLSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    private var retrieveAccessTokenTask: URLSessionDataTask?

    private var newState: String {
        return "GaiaAuthorization-\(Credentials.sharedInstance?.appName ?? "")" +
            "-\(Date().timeIntervalSince1970)"
    }
    private var lastState: String?

    public func startAuthorization() -> URL? {
        let state = newState
        lastState = state
        do {
            return try pageLoader.pageForAuthorization(state: state)
        } catch AuthorizationError.missingApplicationCredentials {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
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

    public func handleRedditRedirectCallback(_ url: URL) {
        guard let credentials = Credentials.sharedInstance else {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
            return
        }
        guard let lastState = lastState else {

        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard components?.host == credentials.redirectUri.host,
            let parameters = components?.queryItems,
            !parameters.isEmpty else {
            failed(with: LoginAuthorizerError.redditError)
            return
        }

        do {
            let code = try CodeFlowAuthorizationProcessComponents
                .extractCode(callbackURIParameters: parameters, sentState: lastState)
            let request = CodeFlowAuthorizationProcessComponents
                .makeAccessTokenURLRequest(credentials: credentials, receivedCode: code)
            retrieveAccessTokenTask = urlSession.dataTask(with: request)
            retrieveAccessTokenTask?.resume()
        } catch let error {
            failed(with: error)
        }
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        if dataTask == retrieveAccessTokenTask {
            do {
                try parseAccessToken(data: data) { (_) in print("hello") }
            } catch AuthorizationError.invalidResponse {
                failed(with: .redditError)
            } catch AuthorizationError.genericRedditError(code: _,
                                                                          message: _) {
                failed(with: .redditError)
            } catch let error as AuthorizationError
                where [.unsupportedGrantType, .noCode, .invalidGrantValue].contains(error) {
                failed(with: .internalError)
            } catch {
                failed(with: .unknownError)
            }
        }
    }
    // TODO: - Move code to a generic parser. Other authorization flows can use this code as well.
    private func parseAccessToken(data: Data, completionHandler: (Token?) -> Void) throws {
        guard let json = (try? JSONSerialization.jsonObject(with: data))
            as? [String: Any] else {
                throw AuthorizationError.invalidResponse
        }

        print(json)
        

        if let token = UserToken(userName: nil, json: json),
            let credentials = Credentials.sharedInstance {
            print(token)
            let request = URLRequest.makeAuthorizedRedditURLRequest(
                url: URL(string: "https://oauth.reddit.com/api/v1/me")!, credentials: credentials,
                token: token)

            urlSession.dataTask(with: request) { [weak self] (data, _, error) in
                guard error == nil, let data = data, let json =
                    (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                        return
                }
                print("\n\nFrom inside the token generator and name retrieval:")
                print(token)
                print(json)
                print("\n\n")
                self?.finishParsingAccessToken(token: token)
            }
        } else {
            throw AuthorizationError.invalidResponse
        }

    }

    private func finishParsingAccessToken(token: Token) {

    }

    private func failed(with error: LoginAuthorizerError) {
        lastState = nil
        retrieveAccessTokenTask = nil
        NotificationCenter.default
            .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                  object: error)

    }
}


// MARK: - User facing errors

/// Errors that might be shown to a user
///
/// - accessDenied: The user has denied access to their account
/// - internalError: Something went wrong with configuring the request
/// - redditError: Something went wrong at Reddit
/// - unknownError: Something went wrong
public enum LoginAuthorizerError: Error {
    case accessDenied
    case internalError
    case redditError
    case unknownError
}

public struct LoginAuthorizerNotifications {
    static let failedAuthorizationName = Notification.Name("failedLoginNotification")
    static let finishedAuthorizationName = Notification.Name("completedLoginNotification")
    static let defaultName = Notification.Name("loginAuthorizerNotification")
}
