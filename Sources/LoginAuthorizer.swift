//
//  OAuthManager.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public class CodeFlowAuthorizer {

    public var flow: CodeFlowAuthorization
    public var delegate: CodeFlowAuthorizerDelegate?

    public init(using flow: CodeFlowAuthorization) {
        self.flow = flow
    }

    private var newState: String {
        return "GaiaAuthorization-\(Date().timeIntervalSince1970)"
    }

    public func startAuthorization() -> URL? {
        let state = newState
        do {
            let url = try flow.startAuthorization(state: state)
            return url
        } catch AuthorizationError.missingApplicationCredentials {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .internalError)
        } catch AuthorizationError.invalidStateString {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .internalError)
        } catch {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .unknownError)
        }
        return nil
    }

    public func handleRedditRedirectCallback(_ url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = components?.queryItems
        components?.queryItems = nil
        guard let calledUri = components?.url, calledUri == flow.appCredentials?.redirectUri,
            let parameters = query else {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .redditError)
            return
        }

        do {
            try flow.handleResponse(callbackURIParameters: parameters)
            try flow.retrieveAccessToken(finishAuthorization: finishAuthorization)
        } catch AuthorizationError.accessDenied {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .accessDenied)
        } catch let error as AuthorizationError
            where [.unsupportedResponseType, .invalidRequest, .invalidScope].contains(error) {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .internalError)
        } catch let error as AuthorizationError
            where [.unknownResponseError, .invalidResponse, .invalidState].contains(error) {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .redditError)
        } catch {
            delegate?.loginAuthorizer(authorizer: self, authorizationFailedWith: .unknownError)
        }
    }

    
    private func finishAuthorization(withError error: Error?) {

    }
}

public protocol CodeFlowAuthorizerDelegate {
    func loginAuthorizer(authorizer: CodeFlowAuthorizer,
                         authorizationFailedWith error: LoginAuthorizerError)

    func loginAuthorizer(authorizer: CodeFlowAuthorizer, didFinishAuthorizing success: Bool)
}

/// Errors tthat might be shown to a user
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
