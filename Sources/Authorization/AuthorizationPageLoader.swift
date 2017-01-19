//
//  AuthorizationPageLoader.swift
//  Helios
//
//  Created by Lars Stegman on 16-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// Generates the url for the page the user has to visit to authorize the application using the code
/// flow.
class AuthorizationPageLoader {
    var compact: Bool = false
    let flowType: AuthorizationFlowType
    var responseType: String {
        return flowType.rawValue
    }

    init(compact: Bool = false, flowType: AuthorizationFlowType) {
        self.compact = compact
        self.flowType = flowType
    }

    var authorizationURL: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = compact ? "/api/v1/authorize.compact" : "/api/v1/authorize"
        return urlComponents
    }

    func pageForAuthorization(state: String) throws -> URL? {
        guard let credentials = Credentials.sharedInstance else {
            throw AuthorizationError.missingApplicationCredentials
        }
        guard let encodedState = state.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed) else {
            throw AuthorizationError.invalidStateString
        }

        var url = authorizationURL
        url.queryItems = [URLQueryItem(name: "client_id", value: credentials.clientId),
                          URLQueryItem(name: "response_type", value: responseType),
                          URLQueryItem(name: "state", value: encodedState),
                          URLQueryItem(name: "redirect_uri",
                                       value: credentials.redirectUri.absoluteString),
                          URLQueryItem(name: "duration",
                                       value: credentials.authorizationDuration.rawValue),
                          URLQueryItem(name: "scope", value: credentials.scopeList)]
        return url.url!
    }

    enum AuthorizationFlowType: String {
        case code
        case implicit = "token"
    }
}

extension Credentials {
    var scopeList: String {
        return authorizationScopes.map( { return $0.rawValue }).joined(separator: " ")
    }
}
