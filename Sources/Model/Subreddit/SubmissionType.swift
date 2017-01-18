//
//  SubmissionType.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum SubmissionType {
    case link
    case `self`
    case any

    init?(text: String) {
        switch text {
        case "any": self = .any
        case "self": self = .self
        case "link": self = .link
        default: return nil
        }
    }
}
