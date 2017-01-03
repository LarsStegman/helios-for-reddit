//
//  SubredditType.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum SubredditType {
    case _public
    case _private
    case restricted
    case goldRestricted
    case archived

    init?(text: String) {
        switch text {
        case "public": self = ._public
        case "private": self = ._private
        case "restricted": self = .restricted
        case "gold_restricted": self = .goldRestricted
        case "archived": self = .archived
        default: return
        }
    }
}
