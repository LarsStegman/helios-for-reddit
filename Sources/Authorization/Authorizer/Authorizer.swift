//
//  AuthorizationFlowDelegate.swift
//  Helios
//
//  Created by Lars Stegman on 27-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// Errors that might be shown to a user
///
/// - accessDenied: The user has denied access to their account.
/// - internalError: Something went wrong with configuring the request.
/// - redditError: Something went wrong at Reddit.
/// - unknownError: Something went wrong.
public enum LoginAuthorizerError: Error {
    case accessDenied
    case `internal`
    case reddit
    case unknown
}

/// A protocol that authorizers can adopt.
public protocol Authorizer {
    /// Start the authorization process.
    func start()

    /// The authorization is canceled. Also use this method if the user cancels the authorization.
    func cancel()

    /// The user has responsed to the authorization request.
    ///
    /// - Parameter url: The response url.
    func authorizationRequestResponse(url: URL)

    /// The delegate for the authorizer.
    var delegate: AuthorizerDelegate? { get set }
}


/// A protocol that authorizer delegates can adopt
public protocol AuthorizerDelegate: class {

    /// The delegate should ask the user to authorize the application for their account.
    ///
    /// - Parameters:
    ///   - authorizer: The authorizer.
    ///   - url: The url at which the user can authorize the application.
    func authorizer(_ authorizer: Authorizer, requestAuthorizationFromUserAt url: URL)

    /// The authorization process has failed.
    ///
    /// - Parameters:
    ///   - authorizer: The authorizer.
    ///   - error: The reason for the failure.
    func authorizer(_ authorizer: Authorizer, authorizationFailedWith error: LoginAuthorizerError)

    /// Authorization has finished.
    ///
    /// - Parameters:
    ///   - authorizer: The authorizer.
    ///   - authorization: The authorization that has been created.
    func authorizer(_ authorizer: Authorizer, authorized authorization: Authorization)
}
