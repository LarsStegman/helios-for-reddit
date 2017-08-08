//
//  AuthorizationRequestResponse.swift
//  Helios
//
//  Created by Lars Stegman on 27-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// Represents a response for an authorization request.
enum AuthorizationRequestResponse {
    case error(AuthorizationRequestResponseError)
    case success(state: String, code: String)

    enum AuthorizationRequestResponseError: String, Error  {
        case accessDenied = "access_denied"
        case unsupportedResponseType = "unsupported_response_type"
        case invalidScope = "invalid_scope"
        case invalidRequest = "invalid_request"
    }

    /// Initialize a authorization request response from url queries.
    ///
    /// - Parameters from: The url queries to parse. These either include an error or a code and a state.
    init?(from queries: [URLQueryItem]) {
        var queryValues: [String: String] = [:]
        for query in queries {
            queryValues[query.name] = query.value
        }

        if let errStr = queryValues["error"], let error = AuthorizationRequestResponseError(rawValue: errStr) {
            self = .error(error)
        } else if let code = queryValues["code"], let state = queryValues["state"] {
            self = .success(state: state, code: code)
        } else {
            return nil
        }
    }
}
