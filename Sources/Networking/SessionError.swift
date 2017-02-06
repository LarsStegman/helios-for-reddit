//
//  SessionError.swift
//  Helios
//
//  Created by Lars Stegman on 06-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum SessionError: Error {
    case unauthorized
    case missingScopeAuthorization(Scope)
    case invalidResponse
    case noResult
    case invalidSource
}
