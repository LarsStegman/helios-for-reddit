//
//  Credentials.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// Credentials will add the `identity` scope automatically to the list of requested scopes, since
/// it's needed to run some internal logic.
public struct Credentials {

    static let sharedInstance = Credentials()

    let appVersion: String
    let bundleIdentifier: String
    let appName: String

    let clientId: String
    let developers: String
    let redirectUri: URL
    let authorizationDuration: AuthorizationDuration
    let authorizationScopes: [Scope]
    let secret: String?
    var userAgentString: String {
        var systemName: String
        #if os(iOS)
            systemName = "iOS"
        #elseif os(macOS)
            systemName = "macOS"
        #else
            systemName = ""
        #endif
        return "\(systemName):\(bundleIdentifier):v\(appVersion) (by \(developers))"
    }
    let secureStoragePrefix: String

    private init?() {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let bundleId = Bundle.main.bundleIdentifier,
            let credentialsPath = Bundle.main.path(forResource: "AppCredentials", ofType: "plist"),
            let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,

            let configDictionary = NSDictionary(contentsOfFile: credentialsPath) as? [String: Any],

            let clientId = configDictionary["client_id"] as? String,
            let developers = configDictionary["developer_reddit_names"] as? [String],
            let uriStr = configDictionary["redirect_uri"] as? String,
            let uri = URL(string: uriStr),
            let durStr = configDictionary["authorization_duration"] as? String,
            let dur = AuthorizationDuration(rawValue: durStr),
            let scopes = configDictionary["scopes"] as? [String],
            let secret = configDictionary["client_secret"] as? String?,
            let secureStoragePrefix = configDictionary["secure_storage_prefix"] as? String else {
                return nil
        }

        self.appVersion = version
        self.bundleIdentifier = bundleId
        self.appName = name
        
        self.clientId = clientId
        self.developers = developers.map({ return "/u/" + $0 }).joined(separator: ", ")
        self.redirectUri = uri
        self.authorizationDuration = dur
        self.authorizationScopes = scopes.flatMap({ return Scope(rawValue: $0) }) + [.identity]
        self.secret = secret
        self.secureStoragePrefix = secureStoragePrefix
        print(self)
    }
}
