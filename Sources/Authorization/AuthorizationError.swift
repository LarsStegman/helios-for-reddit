//
//  AuthorizationError.swift
//  Helios
//
//  Created by Lars Stegman on 17-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// Errors that might occur during the authorization process.
/// These errors are for internal usage only. For errors that the user will see,
/// see `LoginAuthorizerError`
///
/// - accessDenied: The user has denied access to their account.
/// - unsupportedResponseType: The provided response type is not valid
/// - invalidScope: The provided scope string is not valid.
/// - invalidRequest: The parameters of the authorization page were probably not correct.
/// - invalidStateString: The generated state string is not valid in a url.
/// = invalidState: The state Reddit returned was not equal to the state sent during initialization.
/// - invalidResponse: Reddit responded with an unknown response.
/// - genericRedditError: Reddit responded with an error code.
/// - unsupportedGrantType: The type of grant is unsupported.
/// - noCode: No code was included in the code flow
/// - invalidGrantValue: The grant is invalid/expired.
/// - unknown: Unknown error
public enum AuthorizationError: Error, Equatable {

    case accessDenied
    case unsupportedResponseType
    case invalidScope
    case invalidRequest
    case invalidStateString
    case invalidState
    case invalidResponse
    case genericRedditError(code: Int, message: String)
    case unsupportedGrantType
    case unableToRetrieveUserName
    case noCode
    case invalidGrantValue
    case unknown

    public static func ==(lhs: AuthorizationError, rhs: AuthorizationError) -> Bool {
        switch (lhs, rhs) {
        case (let .genericRedditError(code: cL, message: mL),
              let .genericRedditError(code: cR, message: mR)): return cL == cR && mL == mR
        case (.accessDenied, .accessDenied), (.unsupportedResponseType, .unsupportedResponseType),
             (.invalidScope, .invalidScope), (.invalidRequest, .invalidRequest),
             (.invalidStateString, .invalidStateString), (.invalidResponse, .invalidResponse),
             (.unsupportedGrantType, .unsupportedGrantType),
             (.unableToRetrieveUserName, .unableToRetrieveUserName), (.noCode, .noCode),
             (.invalidGrantValue, .invalidGrantValue), (.unknown, .unknown): return true
        default: return false
        }
    }
}
