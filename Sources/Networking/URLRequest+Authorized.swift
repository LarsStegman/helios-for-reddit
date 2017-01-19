//
//  URLRequest+Authorized.swift
//  Helios
//
//  Created by Lars Stegman on 16-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension URLRequest {
    static func makeAuthorizedRedditURLRequest(url: URL, credentials: Credentials, token: Token)
        -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(credentials.userAgentString, forHTTPHeaderField: "User-Agent")

        return request
    }
}
