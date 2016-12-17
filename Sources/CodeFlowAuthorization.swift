//
//  CodeAuthorizationFlow.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public class CodeFlowAuthorization: NSObject, AuthorizationFlow, URLSessionDelegate {

    public var appCredentials: AppCredentials?
    public let responseType = "code"
    public var compact = false
    public let accessTokenURL: URL = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.reddit.com"
        urlComponents.path = "/api/v1/access_token"
        return urlComponents.url!
    }()

    private var lastStartedState: String?
    private var lastReceivedCode: String?


    private lazy var networkSession: URLSession = {
        [unowned self] in
        URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    private var lastAuthorizationTask: URLSessionTask?


    public func startAuthorization(state: String) throws -> URL {
        lastAuthorizationTask?.cancel()
        lastAuthorizationTask = nil
        guard let credentials = appCredentials else {
            throw AuthorizationError.missingApplicationCredentials
        }
        guard let state = state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw AuthorizationError.invalidStateString
        }
        lastStartedState = state
        var url = authorizationURL
        url.queryItems = [URLQueryItem(name: "client_id", value: credentials.clientId),
                          URLQueryItem(name: "response_type", value: responseType),
                          URLQueryItem(name: "state", value: state),
                          URLQueryItem(name: "redirect_uri", value: credentials.redirectUri.absoluteString),
                          URLQueryItem(name: "duration", value: "permanent"),
                          URLQueryItem(name: "scope", value: credentials.scopeList)]
        return url.url!
    }

    public func handleResponse(callbackURIParameters: [URLQueryItem]) throws {
        var parameters = [String: String]()
        for item in callbackURIParameters {
            parameters[item.name] = item.value
        }

        guard parameters["error"] != nil else {
            switch parameters["error"]! {
            case "access_denied" : throw AuthorizationError.accessDenied
            case "unsupported_response_type" : throw AuthorizationError.unsupportedResponseType
            case "invalid_scope" : throw AuthorizationError.invalidScope
            case "invalid_request"  : throw AuthorizationError.invalidRequest
            default: throw AuthorizationError.unknownResponseError
            }
        }

        guard let returnedState = parameters["state"], let receivedCode = parameters["code"] else {
            throw AuthorizationError.invalidResponse
        }

        guard returnedState == lastStartedState  else {
            throw AuthorizationError.invalidState
        }

        lastReceivedCode = receivedCode
    }

    public func retrieveAccessToken(finishAuthorization: (_ authorized: Bool) -> Void) throws {
        guard let credentials = appCredentials else {
            throw AuthorizationError.missingApplicationCredentials
        }
        guard let code = lastReceivedCode else {
            throw CodeFlowAuthorizationError.missingCode
        }

        var request = URLRequest(url: accessTokenURL)
        let authentication = Data("\(credentials.clientId):".utf8).base64EncodedString()
        request.addValue(authentication, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = "grant_type=authorization_code&code=\(code)&redirect_uri=\(credentials.redirectUri.absoluteString)".data(using: .utf8)

        lastAuthorizationTask = networkSession.dataTask(with: request)

        lastAuthorizationTask?.resume()
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard task == lastAuthorizationTask else {
            return
        }
    }
}

// MARK: - Code flow specific errors
/// These errors occur only in the code flow authorization
public enum CodeFlowAuthorizationError: Error {
    /// The authorization while trying to retrieve the access token was invalid.
    case invalidAuthorization

    /// Unsupported grant type, use either "code" or "password".
    case unsupportedGrantType

    /// Include the received code in the POST request body
    case missingCode

    /// The provided code has expired.
    case invalidGrant
}
