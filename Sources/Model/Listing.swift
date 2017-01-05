//
//  Listing.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public struct Listing {
    var before: String?
    var after: String?
    let modhash: String?
    var children: [Thing]
    public static let kind = Kind.listing

    init(before: String?, after: String?, modhash: String?, children: [Thing]) {
        self.before = before
        self.after = after
        self.modhash = modhash
        self.children = children
    }
}
