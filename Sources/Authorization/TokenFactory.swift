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
    
    static func makeUserToken(data: [String: Any],
                       completionHandler: (UserToken?, AuthorizationError?) -> Void) {
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


            urlSession.dataTask(with: request) { (data, _, error) in
                guard error == nil, let data = data, let json =
                    (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] else {
                        return
                }
                print("\n\nFrom inside the token generator and name retrieval:")
                print(token)
                print(json)
                print("\n\n")
                
            }
        }

        completionHandler(nil, AuthorizationError.invalidResponse)
    }

    static func makeApplicationToken(data: [String: Any],
                              completionHandler: (ApplicationToken?, AuthorizationError?) -> Void) {
        if let error = verifyTokenData(json: data) {
            completionHandler(nil, error)
            return
        }


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
