//
//  LoginAuthorizerError.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation


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

