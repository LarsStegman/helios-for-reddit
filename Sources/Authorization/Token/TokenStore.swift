//
//  TokenStore.swift
//  Helios
//
//  Created by Lars Stegman on 18-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation
import Security

public extension Notification.Name {
    
    /// Notifies that refreshing the token failed. The authorization for the token is included in the notification.
    public static let HELTokenStoreTokenRefreshingFailed
        = Notification.Name("HeliosTokenStoreTokenRefreshingFailedNotification")
    
    /// Notifies that a token has been refreshed. The authorization for the refreshed token is included in the
    /// notification.
    public static let HELTokenStoreTokenRefreshed = Notification.Name("HeliosTokenStoreTokenRefreshedNotification")
}


public final class TokenStore {
    private init() { }
    private struct pList {
        static let decoder = PropertyListDecoder()
        static let encoder = PropertyListEncoder()
    }
    private static let requestFactory: AuthorizerRequestFactory = RedditTokenRequestFactory()

    private static var defaults: UserDefaults = UserDefaults()

    /// The currently authorized users/application.
    public private(set) static var authorizations: Set<Authorization> {
        get {
            guard let data = defaults.data(forKey: "helios_authorized_users"),
                let authorizations = try? pList.decoder.decode(Set<Authorization>.self, from: data) else {
                return Set()
            }
            return authorizations
        }
        set {
            if let data = try? pList.encoder.encode(newValue) {
                defaults.set(data, forKey: "helios_authorized_users")
                defaults.synchronize()
            }
        }
    }

    /// Retrieves the a token from storage.
    ///
    /// - Parameter authorization: The 
    /// - Returns:
    static func retrieveToken(for authorization: Authorization) -> Token? {
        guard let data = retrieveSecureTokenData(forAuthorizationType: authorization) else {
            return nil
        }

        let token: Token?
        switch authorization {
        case .user(_): token = try? pList.decoder.decode(UserToken.self, from: data)
        case .application: token = try? pList.decoder.decode(ApplicationToken.self, from: data)
        }

        return token
    }

    /// Revokes a token for a certain authorization. Locally stored tokens are always revoked, however the tokens are
    /// invalided on a best effort basis.
    ///
    /// - Parameter authorization: The authorization to revoke the token for.
    static func revokeToken(for authorization: Authorization) {
        guard authorizations.contains(authorization),
            let token = retrieveToken(for: authorization),
            deleteSecurelyStoredToken(forAuthorization: authorization) else {
            return
        }

        authorizations.remove(authorization)
        revokeRemote(.accessToken, token: token.accessToken)
        if let refresh = token.refreshToken {
            revokeRemote(.refreshToken, token: refresh)
        }
    }

    /// Revokes a token from Reddit
    ///
    /// - Parameters:
    ///   - type: The type of the token to remove
    ///   - token: The token to remove
    private static func revokeRemote(_ tokenType: TokenType, token: String) {
        guard let revokeRequest = requestFactory.createTokenRevokingRequest(token: token, type: tokenType) else {
            return
        }

        let revokeTask = URLSession.shared.dataTask(with: revokeRequest) { (_, response, _) in
            if let response = response as? HTTPURLResponse {
                let logString: String
                if response.statusCode == 204 {
                    logString = "Revoked \(token): \(token) token with response code: \(response.statusCode)"
                } else {
                    logString = "Failed to revoke token with response code: \(response.statusCode)"
                }
                NSLog(logString)
            }
        }
        revokeTask.resume()
    }

    // MARK: - Keychain token storage management.

    static var label = "\(Credentials.sharedInstance.secureStoragePrefix)-reddit-authorization"
    private static var appTokenKey: String {
        return "\(label)-app-authorization"
    }

    /// Removes the token from secure storage.
    ///
    /// - Parameter type: The authorization of the token to remove.
    private static func deleteSecurelyStoredToken(forAuthorization type: Authorization) -> Bool {
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

        let deleteStatus = SecItemDelete(query)
        if deleteStatus == noErr || deleteStatus == errSecItemNotFound {
            authorizations.remove(type)
            return true
        } else {
            return false
        }
    }

    /// Saves the token in secure storage
    ///
    /// - Parameters:
    ///   - key: The key used to identify the token
    ///   - token: The token to be stored
    /// - Returns: Whether the storing succeeded.
    @discardableResult
    static func saveTokenSecurely<T: Token>(token: T) -> Bool {
        let authorization = token.authorizationType
        let deleteOldTokenSuccess = TokenStore.deleteSecurelyStoredToken(forAuthorization: authorization)
        if !deleteOldTokenSuccess {
            return false
        }

        guard let data = try? pList.encoder.encode(token) else {
            return false
        }

        let key: String
        switch authorization {
        case .application: key = appTokenKey
        case .user(name: let name): key = name
        }
        
        let addQuery = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrLabel as String     : label,
            kSecValueData as String     : data,
            kSecAttrAccount as String   : key,
            ] as CFDictionary

        let status = SecItemAdd(addQuery, nil)
        if status == noErr {
            authorizations.insert(authorization)
            return true
        } else {
            return false
        }
    }

    /// Retrieves data from secure storage.
    ///
    /// - Parameter key: The key used to store the authorization.
    /// - Returns: Requested data.
    private static func retrieveSecureTokenData(forAuthorizationType authorization: Authorization) -> Data? {
        let key: String
        switch authorization {
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
