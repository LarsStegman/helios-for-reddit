//
//  TokenStore.swift
//  Helios
//
//  Created by Lars Stegman on 18-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import Security

public class TokenStore {
    private init() { }
    private static var urlSession = URLSession(configuration: .default)

    public private(set) static var authorizations: Set<Authorization> {
        get {
            let stringRepresenations = UserDefaults()
                .stringArray(forKey: "helios_authorized_users") ?? []
            return Set(stringRepresenations.flatMap( { Authorization(rawValue: $0) }))
        }
        set {
            let stringRepresentations = newValue.map({ $0.description })
            UserDefaults().set(stringRepresentations, forKey: "helios_authorized_users")
        }
    }

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

        if let token = UserToken(userName: nil, json: data) {
            let request = URLRequest.makeAuthorizedRedditURLRequest(
                url: URL(string: "https://oauth.reddit.com/api/v1/me")!,
                credentials: Credentials.sharedInstance, token: token)

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
        if let error = verifyTokenData(json: data) {
            completionHandler(nil, error)
            return
        }

        guard let token = ApplicationToken(json: data) else {
            completionHandler(nil, .invalidResponse)
            return
        }

        completionHandler(token, nil)

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

    static var label =
        "\(Credentials.sharedInstance.secureStoragePrefix)-reddit-authorization"
    private static var appTokenKey: String {
        return label + "-app-authorization"
    }

    /// Saves the token in secure storage
    ///
    /// - Parameters:
    ///   - key: The key used to identify the token
    ///   - token: The token to be stored
    /// - Returns: Whether the storing succeeded.
    class func saveToken(forAuthorizationType type: Authorization,
                         token: Token) -> Bool {
        let data = token.data
        let key: String
        switch type {
        case .application: key = appTokenKey
        case .user(name: let name): key = name
        }
        let query = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrLabel as String     : label,
            kSecAttrAccount as String   : key,
        ] as CFDictionary
        SecItemDelete(query)
        
        let addQuery = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrLabel as String     : label,
            kSecValueData as String     : data,
            kSecAttrAccount as String   : key,
            ] as CFDictionary

        let status = SecItemAdd(addQuery, nil)

        if status == noErr {
            authorizations.insert(type)
            print("Stored")
            print(token)
            return true
        } else {
            return false
        }

    }

    /// Retrieves data from secure storage.
    ///
    /// - Parameter key: The key used to store the authorization.
    /// - Returns: Requested data.
    class func retrieveTokenData(forAuthorizationType type: Authorization) -> Data? {
        let key: String
        switch type {
        case .user(name: let name): key = name
        case .application: key = appTokenKey
        }
        let query = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrLabel as String     : label,
            kSecAttrAccount as String   : key,
            kSecReturnData as String    : kCFBooleanTrue,
            kSecMatchLimit as String    : kSecMatchLimitOne,
            ] as CFDictionary
        var resultPointer: AnyObject?
        let lookupStatus = SecItemCopyMatching(query, &resultPointer)

        if lookupStatus == noErr {
            return resultPointer! as? Data
        }
        
        return nil
    }
}
