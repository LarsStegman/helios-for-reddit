//
//  Listing.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public struct Listing: Kindable, Decodable {
    let before: String?
    let after: String?
    let modhash: String?
    var source: URL?

    public let children: [KindWrapper]
    public static let kind = Kind.listing

    init(before: String?, after: String?, modhash: String?, source: URL?, children: [KindWrapper]) {
        self.before = before
        self.after = after
        self.modhash = modhash
        self.source = source
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

    public init(from decoder: Decoder) throws {
        let dataContainer = try decoder.container(keyedBy: CodingKeys.self)
        source = try dataContainer.decodeIfPresent(URL.self, forKey: .source)
        after = try dataContainer.decodeIfPresent(String.self, forKey: .after)
        before = try dataContainer.decodeIfPresent(String.self, forKey: .before)
        modhash = try dataContainer.decodeIfPresent(String.self, forKey: .modhash)
        children = try dataContainer.decode([KindWrapper].self, forKey: .children)
    }
    
    enum CodingKeys: String, CodingKey {
        case before
        case after
        case children
        case modhash
        case source
    }
}
