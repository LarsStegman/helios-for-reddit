//
//  CodeAuthorizationFlow.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public class CodeFlowAuthorization: NSObject, AuthorizationFlow,
    URLSessionTaskDelegate, URLSessionDataDelegate {

    public var appCredentials: AppCredentials?
    public var responseType = "code"
    public var compact = false
    private var authorizationKey: String {
        return (appCredentials?.localAppId ?? "helios") + "-reddit-authorization"
    }
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
        guard let state = state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else {
            throw AuthorizationError.invalidStateString
        }
        lastStartedState = state
        var url = authorizationURL
        url.queryItems = [URLQueryItem(name: "client_id", value: credentials.clientId),
                          URLQueryItem(name: "response_type", value: responseType),
                          URLQueryItem(name: "state", value: state),
                          URLQueryItem(name: "redirect_uri",
                                       value: credentials.redirectUri.absoluteString),
                          URLQueryItem(name: "duration", value: "permanent"),
                          URLQueryItem(name: "scope", value: credentials.scopeList)]
        return url.url!
    }

    public func handleResponse(callbackURIParameters: [URLQueryItem]) throws {
        var parameters = [String: String]()
        for item in callbackURIParameters {
            parameters[item.name] = item.value
        }

        guard parameters["error"] == nil else {
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

    var finishedAuthorization: ((Error?) -> Void)?

    /// This method retrieves the access token from Reddit
    ///
    /// - Parameter finishAuthorization: This closure is called when we have finished retrieving the 
    ///         access token. The error is .Some if something went wrong, in this case the 
    ///         authorization has not succeeded.
    /// - Throws: Some settings should be set before the token can be retrieved
    public func retrieveAccessToken(finishAuthorization: @escaping (_ error: Error?) -> Void) throws {
        guard let credentials = appCredentials else {
            throw AuthorizationError.missingApplicationCredentials
        }
        guard let code = lastReceivedCode else {
            throw CodeFlowAuthorizationError.missingCode
        }
        finishedAuthorization = finishAuthorization
        var request = URLRequest(url: accessTokenURL)
        let authentication = "Basic \("\(credentials.clientId):".data(using: .utf8)!.base64EncodedString())"
        request.addValue(authentication, forHTTPHeaderField: "Authorization")

        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = ("grant_type=authorization_code&code=\(code)&redirect_uri=" +
             "\(credentials.redirectUri.absoluteString)").data(using: .utf8)
        request.addValue(credentials.userAgentString, forHTTPHeaderField: "User-Agent")
        print(credentials.userAgentString)
        lastAuthorizationTask = networkSession.dataTask(with: request)
        lastAuthorizationTask?.resume()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        guard dataTask == lastAuthorizationTask else {
            return
        }

        processAccessTokenData(data: data)
    }

    private func processAccessTokenData(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            as? [String: Any] else {
                finishedAuthorization?(CodeFlowAuthorizationError.invalidResponse)
                return
        }
        print(json)
        guard json["error"] == nil else {
            let message = json["message"] as? String ?? "Failed to authorize"
            let error = json["error"]
            if let errorCode = error as? Int {
                finishedAuthorization?(CodeFlowAuthorizationError
                    .invalidAuthorization(code: errorCode, message: message))
            } else if let errorString = error as? String {
                switch errorString {
                case "unsupported_grant_type": finishedAuthorization?(CodeFlowAuthorizationError.unsupportedGrantType)
                case "NO_TEXT": finishedAuthorization?(CodeFlowAuthorizationError.missingCode)
                case "invalid_grant": finishedAuthorization?(CodeFlowAuthorizationError.invalidGrant)
                default: finishedAuthorization?(CodeFlowAuthorizationError.unknownError)
                }
            }
            return
        }
        storeAccessTokens(from: json)
        lastAuthorizationTask = nil
        lastReceivedCode = nil
    }

    private func storeAccessTokens(from data: [String: Any]) {
        guard let expiresIn = data["expires_in"] as? TimeInterval,
            let refreshToken = data["refresh_token"] as? String,
            let accessToken = data["access_token"] as? String,
            let tokenType = data["token_type"] as? String,
            let scopeString = data["scope"] as? String else {
                return
        }
        let scopes = scopeString.components(separatedBy: " ").map({ return Scope(rawValue: $0)! })
        let expirationDate = Date(timeIntervalSinceNow: expiresIn)
        let authorization = Authorization(accessToken: accessToken, refreshToken: refreshToken,
                                          tokenType: tokenType, scopes: scopes,
                                          expiresAt: expirationDate)
        let success = KeyChainAdapter.saveAuthorization(key: authorizationKey,
                                                        authorization: authorization)
        if success {
            finishedAuthorization?(nil)
        } else {
            finishedAuthorization?(AuthorizationError.failedToStoreAuthorizationCredentials)
        }
    }
}



// MARK: - Code flow specific errors
/// These errors occur only in the code flow authorization
public enum CodeFlowAuthorizationError: Error {
    case invalidResponse

    /// The authorization while trying to retrieve the access token was invalid.
    case invalidAuthorization(code: Int, message: String)

    /// Unsupported grant type, use either "code" or "password".
    case unsupportedGrantType

    /// Include the received code in the POST request body
    case missingCode

    /// The provided code has expired.
    case invalidGrant

    case unknownError
}
