//
//  Authorization.swift
//  Helios
//
//  Created by Lars Stegman on 05-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum Authorization: CustomStringConvertible, Hashable, Codable {
    case user(name: String)
    case application

    public var description: String {
        switch self {
        case .user(name: let name): return "user(\(name))"
        case .application: return "application"
        }
    }

    public var hashValue: Int {
        switch self {
        case .user(name: let name): return name.hashValue
        case .application: return 0
        }
    }

    public static func ==(lhs: Authorization, rhs: Authorization) -> Bool {
        switch (lhs, rhs) {
        case (.user(let nameL), .user(let nameR)): return nameL == nameR
        case (.application, .application): return true
        default: return false
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AuthorizationCodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        if type == "application" {
            self = .application
        } else {
            self = .user(name: try container.decode(String.self, forKey: .value))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AuthorizationCodingKeys.self)
        if case .user(let name) = self {
            try container.encode("user", forKey: .type)
            try container.encode(name, forKey: .value)
        } else if self == .application {
            try container.encode("application", forKey: .type)
        }
    }

    private enum AuthorizationCodingKeys: String, CodingKey {
        case type
        case value
    }
}
