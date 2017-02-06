//
//  Authorization.swift
//  Helios
//
//  Created by Lars Stegman on 05-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum Authorization: CustomStringConvertible, Hashable {
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

    public init?(rawValue: String) {
        switch rawValue {
        case "application": self = .application
        case let str:
            let regex = try! NSRegularExpression(pattern: "user\\(([^\\)]+)\\)",
                                                 options: .caseInsensitive)
            let matches = regex.matches(in: str, range: NSRange(0..<(str as NSString).length))
            if matches.count > 0,
                let range = matches[0].rangeAt(1).toRange() {
                let name = str[range]
                self = .user(name: name)
            } else {
                return nil
            }
        }
    }
}
