//
//  UserCodeFlowProcessAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// Notifications for the code flow authorization process.
public extension Notification.Name {
    /// The authorization has failed.
    public static let failedAuthorization = Notification.Name("failedLoginNotification")

    /// The authorization has succeeded.
    public static let finishedAuthorization = Notification.Name("completedLoginNotification")
}

/// Handles the Code Flow Authorization process for a user which wants to authorize the application.
public class UserCodeFlowAuthorizer: NSObject, Authorizer, URLSessionTaskDelegate, URLSessionDataDelegate {

    public static let sharedInstance = UserCodeFlowAuthorizer()
    public weak var delegate: AuthorizerDelegate?

    public var compactAuthorizationPage = false

    private lazy var urlSession = { [unowned self] in
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    private var retrieveAccessTokenTask: URLSessionDataTask?

    private func createAuthorizationContext() -> AuthorizationContext {
        let newState = "GaiaAuthorization-\(Credentials.sharedInstance.appName)-\(Date().timeIntervalSince1970)"
        let redirectUri = Credentials.sharedInstance.redirectUri
        let scopes = Credentials.sharedInstance.authorizationScopes
        let clientId = Credentials.sharedInstance.clientId

        return AuthorizationContext(redirectUri: redirectUri, grantType: .authorizationCode,
                                    preferredDuration: .permanent, clientId: clientId, responseType: .code,
                                    compact: compactAuthorizationPage, scopes: scopes, sentState: newState,
                                    receivedState: nil, receivedCode: nil)
    }
    private var lastContext: AuthorizationContext?

    public func start() {
        guard delegate != nil else {
            return
        }

        lastContext = createAuthorizationContext()
        let url = lastContext!.authorizationUrl()
        delegate?.authorizer(self, requestAuthorizationFromUserAt: url)
    }

    public func cancel() {
        delegate?.authorizer(self, authorizationFailedWith: .accessDenied)
        reset()
    }

    public func reset() {
        lastContext = nil
        authorizingToken = nil
        retrieveAccessTokenTask = nil
    }

    private let errorMapping: [AuthorizationRequestResponse.AuthorizationRequestResponseError: LoginAuthorizerError] = [
        .accessDenied: .accessDenied
    ]

    /// Call when the user has granted or denied authorization. The url should be the redirect url
    /// of your application including the parameters Reddit has filled in.
    ///
    /// - Parameter url: The redirect url containing the parameters.
    public func authorizationRequestResponse(url: URL) {
        updateContextAfterAuthorizationRequestResponse(url: url)
        requestAccessToken()
    }

    private func updateContextAfterAuthorizationRequestResponse(url: URL) {
        guard let context = lastContext else {
            delegate?.authorizer(self, authorizationFailedWith: .internal)
            return
        }

        do {
            let response = try RedditAuthorizationCallbackValidation().validate(url: url, parameters: context)
            switch response {
            case .error(let error):
                reset()
                delegate?.authorizer(self, authorizationFailedWith: errorMapping[error] ?? .internal)
            case .success(state: let receivedState, code: _) where receivedState != lastContext?.sentState:
                reset()
                delegate?.authorizer(self, authorizationFailedWith: .reddit)
            case .success(state: let state, code: let code):
                lastContext?.receivedState = state
                lastContext?.receivedCode = code
            }
        } catch let error as LoginAuthorizerError {
            lastContext = nil
            delegate?.authorizer(self, authorizationFailedWith: error)
            return
        } catch {
            return
        }
    }

    private lazy var requestFactory = RedditTokenRequestFactory()

    private func requestAccessToken() {
        guard let context = lastContext,
            let request = requestFactory.createTokenRetrievalRequest(context: context) else {
            return
        }
        
        retrieveAccessTokenTask = urlSession.dataTask(with: request)
        retrieveAccessTokenTask?.resume()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if dataTask == retrieveAccessTokenTask {
            guard !isError(data: data) else {
                delegate?.authorizer(self, authorizationFailedWith: .internal)
                return
            }
            createUserToken(from: data)
            loadIdentityIntoToken()
            retrieveAccessTokenTask = nil
        }
    }

    private let decoder = JSONDecoder()
    private var authorizingToken: UserToken? = nil

    private func isError(data: Data) -> Bool {
        return (try? decoder.decode(TokenRetrievalErrorResponse.self, from: data)) != nil
    }

    private func createUserToken(from data: Data) {
        guard let userToken = try? decoder.decode(UserToken.self, from: data) else {
            delegate?.authorizer(self, authorizationFailedWith: .reddit)
            return
        }

        authorizingToken = userToken
    }

    private func loadIdentityIntoToken() {
        guard let token = authorizingToken else {
            return
        }

        let userSession = HELSession(token: token)
        userSession.identity(result: { [weak self] (identity) in
            self?.authorizingToken = UserToken(username: identity.username, token: token)
            self?.storeToken(for: identity.username)
        }, error: { [weak self] (error) in
            self?.delegate?.authorizer(self!, authorizationFailedWith: .reddit)
            self?.reset()
        })
    }

    private func storeToken(for username: String) {
        guard let token = authorizingToken else {
            return
        }

        let stored = TokenStore.saveTokenSecurely(token: token, forAuthorization: .user(name: username))
        if stored {
            delegate?.authorizer(self, authorized: .user(name: username))
        } else {
            delegate?.authorizer(self, authorizationFailedWith: .internal)
        }

        reset()
    }
}
