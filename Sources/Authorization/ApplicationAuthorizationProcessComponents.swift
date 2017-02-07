//
//  ApplicationAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 24-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class ApplicationAuthorizationProcessComponents: AuthorizationProcessComponents {

    class func makeAccessTokenURLRequest() -> URLRequest {
        var request = super.makeAccessTokenURLRequest()
        let body: String
        switch Credentials.sharedInstance.appType {
        case .installed: body = "grant_type=\(GrantType.installedClient.rawValue)" +
        "&device_id=\(Credentials.sharedInstance.uuid.uuidString)"
        case .webapp, .script: body = "grant_type=\(GrantType.clientCredentials.rawValue)"
        }
        request.httpBody = body.data(using: .utf8)
        return request
    }
}
