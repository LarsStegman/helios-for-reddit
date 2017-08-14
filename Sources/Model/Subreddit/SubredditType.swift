//
//  SubredditType.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum SubredditType: String, Decodable {
    case `public`
    case `private`
    case restricted
    case goldRestricted = "gold_only"
    case archived
}
