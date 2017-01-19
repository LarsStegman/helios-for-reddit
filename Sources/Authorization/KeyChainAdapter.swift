//
//  KeychainAdapter.swift
//  Helios
//
//  Created by Lars Stegman on 28-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation
import Security

class KeyChainAdapter {

    static var label =
        (Credentials.sharedInstance?.secureStoragePrefix ?? "helios") + "-reddit-authorization"

    /// Saves the token in secure storage
    ///
    /// - Parameters:
    ///   - key: The key used to identify the token
    ///   - token: The token to be stored
    /// - Returns: Whether the storing succeeded.
    class func saveToken(forKey key: String,
                         token: Token) -> Bool {
        let data = token.data
        let query = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrLabel as String     : label,
            kSecAttrAccount as String   : key,
            kSecValueData as String     : data
        ] as CFDictionary

        SecItemDelete(query)
        let status = SecItemAdd(query, nil)

        return status == noErr
    }

    /// Retrieves data from secure storage.
    ///
    /// - Parameter key: The key used to store the authorization.
    /// - Returns: Requested data.
    class func retrieveTokenData(forKey key: String) -> Data? {
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
