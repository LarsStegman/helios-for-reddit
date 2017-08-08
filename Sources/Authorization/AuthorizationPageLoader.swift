//
//  AuthorizationPageLoader.swift
//  Helios
//
//  Created by Lars Stegman on 16-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

protocol AuthorizationLocationCreator {
    func urlForAuthorization(using parameters: AuthorizationParameters) throws -> URL
}

protocol AuthorizationParameters {
    var clientId: String { get }
    var redirectUri: URL { get }
    var scopes: [Scope] { get }
    var preferredDuration: AuthorizationDuration { get }
    var sentState: String { get }
    var responseType: AuthorizationFlowType { get }
}

extension AuthorizationParameters {
    var scopeList: String {
        return scopes.map( { return $0.rawValue }).joined(separator: " ")
    }
}

extension AuthorizationContext: AuthorizationParameters {}

/// Creates the URL at which users can authorize an application 
struct AuthorizationPageLoader: AuthorizationLocationCreator {
    var compact: Bool = false
    init(compact: Bool = false) {
        self.compact = compact
    }

    private var authorizationURL: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = compact ? "/api/v1/authorize.compact" : "/api/v1/authorize"
        return urlComponents
    }

    /// Generates the url where the user can authorize the application
    ///
    /// - Parameter parameters: <#parameters description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    func urlForAuthorization(using parameters: AuthorizationParameters) throws -> URL {
        guard let encodedState = parameters.sentState.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AuthorizationError.invalidStateString
        }

        var url = authorizationURL
        url.queryItems = [URLQueryItem(name: "client_id", value: parameters.clientId),
                          URLQueryItem(name: "response_type", value: parameters.responseType.rawValue),
                          URLQueryItem(name: "state", value: encodedState),
                          URLQueryItem(name: "redirect_uri", value: parameters .redirectUri.absoluteString),
                          URLQueryItem(name: "duration", value: parameters.preferredDuration.rawValue),
                          URLQueryItem(name: "scope", value: parameters.scopeList)]
        return url.url!
    }
}
