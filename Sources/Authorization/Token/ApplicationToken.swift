//
//  ApplicationToken.swift
//  Helios
//
//  Created by Lars Stegman on 13-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct ApplicationToken: Token {
    let accessToken: String
    let scopes: [Scope]
    let expiresAt: Date
    var authorizationType: TokenStore.AuthorizationType {
        return .application
    }

    init(accessToken: String, scopes: [Scope], expiresAt: Date) {
        self.accessToken = accessToken
        self.scopes = scopes
        self.expiresAt = expiresAt
    }

    init?(json: [String: Any]) {
        guard let accessToken = json["access_token"] as? String,
            let scope = json["scope"] as? String,
            scope == "*",
            let expiresIn = json["expires_in"] as? TimeInterval else {
                return nil
        }
        let scopes = [Scope.read]
        self = ApplicationToken(accessToken: accessToken, scopes: scopes,
                                expiresAt: Date(timeIntervalSinceNow: expiresIn))

    }

    var data: Data {
        let propertyList =  [encodingKeys.accessToken : accessToken,
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
            let scopesVal = dict[encodingKeys.scopes] as? [String],
            let expiresAtVal = dict[encodingKeys.expiresAt] as? TimeInterval else {
                return nil
        }

        let scopes = scopesVal.map({ return Scope(rawValue: $0)! })
        let date = Date(timeIntervalSince1970: expiresAtVal)

        self = ApplicationToken(accessToken: accessTokenVal, scopes: scopes, expiresAt: date)
    }

    private struct encodingKeys {
        static let accessToken = "accessToken"
        static let scopes = "scopes"
        static let expiresAt = "expiresAt"
    }
}
