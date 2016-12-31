//
//  Distinguishment.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public enum Distinguishment {
    case admin
    case moderator
    case special(name: String)

    init(text: String) {
        switch text {
        case "moderator": self = .moderator
        case "admin": self = .admin
        default: self = .special(name: text)
        }
    }
}
