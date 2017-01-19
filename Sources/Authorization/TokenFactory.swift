//
//  TokenFactory.swift
//  Helios
//
//  Created by Lars Stegman on 18-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class TokenFactory {
    private init() { }
    private static var urlSession = URLSession(configuration: .default)
    
    /// Creates a user token
    ///
    /// - Parameters:
    ///   - data: JSON containing either a user token object, or some error message
    ///   - completionHandler: This is called when the user token has been generated.
    static func makeUserToken(data: [String: Any],
                       completionHandler: @escaping (UserToken?, AuthorizationError?) -> Void) {
        if let error = verifyTokenData(json: data) {
            completionHandler(nil, error)
            return
        }

        if let token = UserToken(userName: nil, json: data),
            let credentials = Credentials.sharedInstance {
            print(token)
            let request = URLRequest.makeAuthorizedRedditURLRequest(
                url: URL(string: "https://oauth.reddit.com/api/v1/me")!, credentials: credentials,
                token: token)

            let task = urlSession.dataTask(with: request) { (data, _, error) in
                guard error == nil, let data = data, let json =
                    (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                    let name = json["name"] as? String else {
                        completionHandler(nil, .unableToRetrieveUserName)
                        return
                }
                let tokenWithUserName = UserToken(userName: name, accessToken: token.accessToken,
                                                  refreshToken: token.refreshToken,
                                                  scopes: token.scopes, expiresAt: token.expiresAt)

                completionHandler(tokenWithUserName, nil)
            }
            task.resume()
        } else {
            completionHandler(nil, .invalidResponse)
        }
    }

    
    static func makeApplicationToken(data: [String: Any],
                              completionHandler: @escaping (ApplicationToken?, AuthorizationError?)
                                                            -> Void) {
        // - TODO: Implement

    }

    private static func verifyTokenData(json: [String: Any]) -> AuthorizationError? {
        if let error = json["error"] {
            let message = json["message"] as? String ?? "Failed to authorize"
            if let errorCode = error as? Int {
                return AuthorizationError.genericRedditError(code: errorCode, message: message)
            } else if let errorString = error as? String {
                switch errorString {
                case "access_denied": return AuthorizationError.accessDenied
                case "unsupported_grant_type": return AuthorizationError.unsupportedGrantType
                case "NO_TEXT": return AuthorizationError.noCode
                case "invalid_grant": return AuthorizationError.invalidGrantValue
                default: return AuthorizationError.unknown
                }
            }
            return AuthorizationError.unknown
        }
        return nil
    }
}
