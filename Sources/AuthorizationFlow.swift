//
//  AuthorizationFlow.swift
//  Helios
//
//  Created by Lars Stegman on 16-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol AuthorizationFlow {

    /// The credentials of the application.
    var appCredentials: AppCredentials? { get set }

    /// The response type the flow expects to receive from Reddit
    var responseType: String { get }

    /// The url of the page on which the user authorizes the application.
    var authorizationURL: URLComponents { get }

    /// Whether the user is on a compact device or not. This is used to determine what authorization
    /// page to open
    var compact: Bool { get set }

    /// Starts the authorization progress
    ///
    /// - Parameter state: The state of this authorization request. This value is stored to be 
    ////  compared to the received response in `handleResponse`. This value should be valid inside 
    ///   a url query component.
    /// - Returns: The URL you should send the user to, to authorize your application
    /// - Throws: You should have provided application credentials and the state value should be 
    ///   valid inside a url query
    func startAuthorization(state: String) throws -> URL

    /// When Reddit redirects to the callback url, this method should be called.
    ///
    /// - Parameter callbackURIParameters: The parameters in the callback uri
    /// - Throws: AuthorizationError. The user might deny access, or an error has occurred at Reddit
    func handleResponse(callbackURIParameters: [URLQueryItem]) throws


    /// Retrieves the token from Reddit
    ///
    /// - Parameter finishAuthorization: We need to access the network to request the access token
    ///   which is asynchronous.
    /// - Throws:
    func retrieveAccessToken(finishAuthorization: @escaping (_ error: Error?) -> Void) throws
}

public extension AuthorizationFlow {
    var authorizationURL: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = compact ? "/api/v1/authorize.compact" : "/api/v1/authorize" 
        return urlComponents
    }
}

internal extension AppCredentials {
    var scopeList: String {
        return authorizationScopes.map( { $0.rawValue }).joined(separator: ",")
    }
}

public enum AuthorizationError: Error {
    
    /// Reddit Request Errors

    /// The user has denied access to its account
    case accessDenied

    /// Unsupported response type
    /// See https://github.com/reddit/reddit/wiki/OAuth2 for more information
    case unsupportedResponseType

    /// One or more of the requested scopes is not valid
    /// See https://www.reddit.com/api/v1/scopes for a list of valid scopes
    case invalidScope

    /// One or more of the parameters in the authorization url ("/api/v1/authorize") was misformed
    case invalidRequest

    /// Reddit has returned some kind of error, but we don't know what.
    case unknownResponseError


    // Internal errors

    /// The state in the redirect URI was not equal to the state in the authorization url.
    case invalidState

    /// The state string is not valid to be embedded in a url query item.
    case invalidStateString

    /// Include application credentials to be used to identify yourself to Reddit.
    case missingApplicationCredentials

    /// Reddit didn't give us the needed information :(
    case invalidResponse
}
