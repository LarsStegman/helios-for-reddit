//
//  AccessTokenRetrievalResponse.swift
//  Helios
//
//  Created by Lars Stegman on 01-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

enum TokenRetrievalErrorResponse: String, Decodable {
    case invalidAuthentication = "401"
    case unsupportedGrantType = "unsupported_grant_type"
    case noCode = "NO_TEXT"
    case invalidGrant = "invalid_grant"

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if (try? container.decode(Int.self, forKey: .error)) != nil {
            self = .invalidAuthentication
        } else {
            self = TokenRetrievalErrorResponse(rawValue: try container.decode(String.self, forKey: .error))!
        }
    }

    private enum CodingKeys: String, CodingKey {
        case message
        case error
    }
}
