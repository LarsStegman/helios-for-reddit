//
//  ApiError.swift
//  Helios
//
//  Created by Lars Stegman on 22-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct ApiError: Codable {
    let message: String
    let error: Int

    var sessionError: SessionError? {
        switch self.error {
        case 401: return .unauthorized
        default: return nil
        }
    }
}
