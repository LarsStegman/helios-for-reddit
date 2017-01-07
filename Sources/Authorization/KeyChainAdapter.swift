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

    class func saveAuthorization(key: String, authorization: Authorization) -> Bool {
        let data = authorization.data
        
        let query = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrAccount as String   : key,
            kSecValueData as String     : data
        ] as CFDictionary

        SecItemDelete(query)
        let status = SecItemAdd(query, nil)

        return status == noErr
    }

    class func retrieveAuthorization(forKey key: String) -> Authorization? {
        let query = [
            kSecClass as String         : kSecClassGenericPassword,
            kSecAttrAccount as String   : key,
            kSecReturnData as String    : kCFBooleanTrue,
            kSecMatchLimit as String    : kSecMatchLimitOne,
        ] as CFDictionary
        var resultPointer: AnyObject?
        let lookupStatus = SecItemCopyMatching(query, &resultPointer)

        if lookupStatus == noErr {
            return Authorization(from: (resultPointer! as! Data))
        }

        return nil
    }
}

private extension Authorization {
    var data: Data {
        let propertyList =  [encodingKeys.accessToken : accessToken,
                             encodingKeys.refreshToken: refreshToken,
                             encodingKeys.tokenType : tokenType,
                             encodingKeys.scopes : scopes.map( { return $0.rawValue } ),
                             encodingKeys.expiresAt : expiresAt.timeIntervalSince1970] as [String: Any]

        return try! PropertyListSerialization.data(fromPropertyList: propertyList,
                                                   format: .binary, options: .allZeros)
    }

    init?(from data: Data) {
        guard let dict =
            (try? PropertyListSerialization.propertyList(from: data,
                                                         options: .mutableContainersAndLeaves,
                                                         format: nil)) as? [String: Any],
            let accessTokenVal = dict[encodingKeys.accessToken] as? String,
            let refreshTokenVal = dict[encodingKeys.refreshToken] as? String,
            let tokenTypeVal = dict[encodingKeys.tokenType] as? String,
            let scopesVal = dict[encodingKeys.scopes] as? [String],
            let expiresAtVal = dict[encodingKeys.expiresAt] as? TimeInterval else {
                return nil
        }

        let scopes = scopesVal.map({ return Scope(rawValue: $0)! })
        let date = Date(timeIntervalSince1970: expiresAtVal)

        self.accessToken = accessTokenVal
        self.refreshToken = refreshTokenVal
        self.tokenType = tokenTypeVal
        self.scopes = scopes
        self.expiresAt = date
    }

    private struct encodingKeys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let tokenType = "tokenType"
        static let scopes = "scopes"
        static let expiresAt = "expiresAt"
    }
}
