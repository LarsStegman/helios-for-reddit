//
//  ApplicationAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class ApplicationAuthorizationProcessComponents: AuthorizationProcessComponents {

    override class func makeAccessTokenURLRequest(credentials: Credentials) -> URLRequest {
        var request = super.makeAccessTokenURLRequest(credentials: credentials)
        let body: String
        switch credentials.appType {
        case .installed: body = "grant_type=\(GrantType.installedClient)" +
        "&device_id=\(credentials.uuid.uuidString)"
        case .webapp, .script: body = "grant_type=\(GrantType.clientCredentials)"
        }
        request.httpBody = body.data(using: .utf8)
        return request
    }
}
