//
//  UserToken.swift
//  Helios
//
//  Created by Lars Stegman on 13-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct UserToken: Token {
    let userName: String?
    let accessToken: String
    let refreshToken: String?
    let scopes: [Scope]
    let expiresAt: Date
    var authorizationType: Authorization {
        if let name = userName {
            return .user(name: name)
        } else {
            return .application
        }
    }

    init(userName: String?, accessToken: String, refreshToken: String?, scopes: [Scope],
         expiresAt: Date) {
        self.userName = userName
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.scopes = scopes
        self.expiresAt = expiresAt
    }

    init?(userName: String?, json: [String: Any]) {
        guard let token = json["access_token"] as? String,
            let refreshToken = json["refresh_token"] as? String?,
            let scope = json["scope"] as? String,
            let expiresIn = json["expires_in"] as? TimeInterval else {
                return nil
        }

        let scopes = scope.components(separatedBy: " ").map({ return Scope(rawValue: $0)! })
        self = UserToken(userName: userName, accessToken: token, refreshToken: refreshToken,
                         scopes: scopes, expiresAt: Date(timeIntervalSinceNow: expiresIn))
    }

    var data: Data {
        let propertyList =  [encodingKeys.accessToken : accessToken,
                             encodingKeys.refreshToken: refreshToken as Any,
                             encodingKeys.userName : userName as Any,
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
            let userNameVal = dict[encodingKeys.userName] as? String?,
            let scopesVal = dict[encodingKeys.scopes] as? [String],
            let expiresAtVal = dict[encodingKeys.expiresAt] as? TimeInterval else {
                return nil
        }

        let scopes = scopesVal.map({ return Scope(rawValue: $0)! })
        let date = Date(timeIntervalSince1970: expiresAtVal)

        self = UserToken(userName: userNameVal, accessToken: accessTokenVal, refreshToken: refreshTokenVal, scopes: scopes, expiresAt: date)
    }

    private struct encodingKeys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userName = "userName"
        static let scopes = "scopes"
        static let expiresAt = "expiresAt"
    }
}

