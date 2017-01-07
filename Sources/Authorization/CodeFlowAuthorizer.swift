//
//  OAuthManager.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public class CodeFlowAuthorizer {

    public var flow: AuthorizationFlow
    public struct LoginAuthorizerNotifications {
        static let failedAuthorizationName = Notification.Name("failedLoginNotification")
        static let finishedAuthorizationName = Notification.Name("completedLoginNotification")
        static let defaultName = Notification.Name("loginAuthorizerNotification")
    }
    
    public init(using flow: AuthorizationFlow) {
        self.flow = flow
    }

    private var newState: String {
        return "GaiaAuthorization-\(flow.appCredentials?.localAppId ?? "")" +
            "-\(Date().timeIntervalSince1970)"
    }

    public func startAuthorization() -> URL? {
        let state = newState
        do {
            return try flow.startAuthorization(state: state)
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
        return nil
    }

    public func handleRedditRedirectCallback(_ url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = components?.queryItems
        components?.queryItems = nil
        guard let calledUri = components?.url, calledUri == flow.appCredentials?.redirectUri,
            let parameters = query else {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.redditError)
            return
        }

        do {
            try flow.handleResponse(callbackURIParameters: parameters)
            try flow.retrieveAccessToken(finishAuthorization: finishAuthorization)
        } catch AuthorizationError.accessDenied {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.accessDenied)
        } catch let error as AuthorizationError
            where [.unsupportedResponseType, .invalidRequest, .invalidScope].contains(error) {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
        } catch let error as AuthorizationError
            where [.unknownResponseError, .invalidResponse, .invalidState].contains(error) {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.redditError)
        } catch {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                      object: LoginAuthorizerError.unknownError)
        }
    }

    
    /// Call when the authorization has finished
    ///
    /// - Parameter error: The error if one has occured.
    private func finishAuthorization(withError error: Error?) {
        guard let error = error else {
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.finishedAuthorizationName, object: nil)
            return
        }

        switch error {
        case CodeFlowAuthorizationError.invalidResponse:
            NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.finishedAuthorizationName,
                      object: LoginAuthorizerError.redditError)
        case CodeFlowAuthorizationError.invalidAuthorization(code: _, message: _),
             CodeFlowAuthorizationError.unsupportedGrantType,
             CodeFlowAuthorizationError.missingCode,
             CodeFlowAuthorizationError.invalidGrant,
             AuthorizationError.failedToStoreAuthorizationCredentials: NotificationCenter.default
                .post(name: LoginAuthorizerNotifications.finishedAuthorizationName,
                      object: LoginAuthorizerError.internalError)
        default: NotificationCenter.default
            .post(name: LoginAuthorizerNotifications.failedAuthorizationName,
                  object: LoginAuthorizerError.unknownError)
        }
    }
}



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
