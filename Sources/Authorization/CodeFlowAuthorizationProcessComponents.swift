//
//  CFACodeExtractor.swift
//  Helios
//
//  Created by Lars Stegman on 16-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class CodeFlowAuthorizationProcessComponents {
    private init() { }
    
    static func extractCode(callbackURIParameters: [URLQueryItem], sentState: String)
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

    private static let accessTokenURL = URL(string: "https://www.reddit.com/api/v1/access_token")!

    /// Creates a request object that requests an access token from Reddit.
    ///
    /// - Parameters:
    ///   - credentials: The credentials to use for the request
    ///   - receivedCode: The code received after the user has granted access.
    /// - Returns: The URLRequest which contains the request for an access token.
    static func makeAccessTokenURLRequest(credentials: Credentials, receivedCode: String) -> URLRequest {
        var request = URLRequest(url: accessTokenURL)

        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(credentials.userAgentString, forHTTPHeaderField: "User-Agent")
        let authorization = "Basic " +
                "\(credentials.clientId):".data(using: .utf8)!.base64EncodedString()
        request.addValue(authorization, forHTTPHeaderField: "Authorization")

        request.httpBody = ("grant_type=authorization_code&code=\(receivedCode)&redirect_uri=" +
            "\(credentials.redirectUri.absoluteString)").data(using: .utf8)

        return request
    }

}
