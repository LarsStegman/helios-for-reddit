//
//  CodeFlowAuthorizationProcessComponents.swift
//  Helios
//
//  Created by Lars Stegman on 16-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class CodeFlowAuthorizationProcessComponents: AuthorizationProcessComponents {
    
    class func extractCode(callbackURIParameters: [URLQueryItem], sentState: String)
            throws -> String {
        var parameters = callbackURIParameters.reduce([String: String]()) { (result, item) in
            var result = result
            result[item.name] = item.value
            return result
        }

        if let error = parameters["error"] {
            switch error {
            case "access_denied" : throw AuthorizationError.accessDenied
            case "unsupported_response_type" : throw AuthorizationError.unsupportedResponseType
            case "invalid_scope" : throw AuthorizationError.invalidScope
            case "invalid_request"  : throw AuthorizationError.invalidRequest
            default: throw AuthorizationError.unknown
            }
        }

        guard let returnedState = parameters["state"], let receivedCode = parameters["code"] else {
            throw AuthorizationError.invalidResponse
        }

        guard returnedState == sentState else {
            throw AuthorizationError.invalidState
        }

        return receivedCode
    }

    class func makeAccessTokenURLRequest(credentials: Credentials,
                                                   receivedCode: String) -> URLRequest {
        var request = super.makeAccessTokenURLRequest(credentials: credentials)
        let postData = "grant_type=\(GrantType.authorizationCode.rawValue)&code=" +
            "\(receivedCode)&redirect_uri=\(credentials.redirectUri.absoluteString)"

        request.httpBody = postData.data(using: .utf8)
        return request
    }

}
