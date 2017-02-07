//
//  AuthorizationProcessComponents.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class AuthorizationProcessComponents {
    private init() { }
    static let accessTokenURL = URL(string: "https://www.reddit.com/api/v1/access_token")!

    /// Creates a request object that requests an access token from Reddit.
    ///
    /// - Parameters:
    ///   - credentials: The credentials to use for the request
    ///   - receivedCode: The code received after the user has granted access.
    /// - Returns: The URLRequest which contains the request for an access token.
    class func makeAccessTokenURLRequest(url: URL = accessTokenURL) -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(Credentials.sharedInstance.userAgentString, forHTTPHeaderField: "User-Agent")
        let authorization = "Basic " +
            "\(Credentials.sharedInstance.clientId):".data(using: .utf8)!.base64EncodedString()
        request.addValue(authorization, forHTTPHeaderField: "Authorization")

        return request
    }
}
