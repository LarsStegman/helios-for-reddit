//
//  AuthorizationContext.swift
//  Helios
//
//  Created by Lars Stegman on 27-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// Holds all contextual information for an authorization process.
struct AuthorizationContext {
    let redirectUri: URL
    let grantType: GrantType
    let preferredDuration: AuthorizationDuration
    let clientId: String
    let responseType: AuthorizationFlowType

    let compact: Bool
    let scopes: [Scope]
    let sentState: String
    var receivedState: String? = nil
    var receivedCode: String? = nil

    private var scopeList: String {
        return scopes.map( { return $0.rawValue }).joined(separator: " ")
    }

    func authorizationUrl() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = compact ? "/api/v1/authorize.compact" : "/api/v1/authorize"
        let encodedState = sentState.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "INVALID_STATE"

        urlComponents.queryItems = [URLQueryItem(name: "client_id", value: clientId),
                                    URLQueryItem(name: "response_type", value: responseType.rawValue),
                                    URLQueryItem(name: "state", value: encodedState),
                                    URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
                                    URLQueryItem(name: "duration", value: preferredDuration.rawValue),
                                    URLQueryItem(name: "scope", value: scopeList)]

        return urlComponents.url!
    }
}
