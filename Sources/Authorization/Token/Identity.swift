//
//  Identity.swift
//  Helios
//
//  Created by Lars Stegman on 08-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct Identity: Codable {
    let username: String

    private enum CodingKeys: String, CodingKey {
        case username = "name"
    }
}

extension HELSession {
    func identity(result: @escaping ResultHandler<Identity>, error: @escaping ErrorHandler) {
        guard authorized(for: .identity) else {
            error(.missingScopeAuthorization(.identity))
            return
        }

        let identityUrl = URL(string: "api/v1/me", relativeTo: apiHost)!
        queueTask(url: identityUrl, result: result, error: error)
    }
}
