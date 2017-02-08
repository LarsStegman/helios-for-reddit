//
//  Listing.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public struct Listing {
    let before: String?
    let after: String?
    let modhash: String?
    var source: URL?

    public let children: [Thing]
    public static let kind = Kind.listing

    init(before: String?, after: String?, modhash: String?, children: [Thing]) {
        self.before = before
        self.after = after
        self.modhash = modhash
        self.children = children
    }

    /// Whether there are pages before this one.
    public var hasPrevious: Bool {
        return before != nil
    }

    /// Whether there are more pages.
    public var hasNext: Bool {
        return after != nil
    }
}
