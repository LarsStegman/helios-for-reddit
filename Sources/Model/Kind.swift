//
//  Kind.swift
//  Helios
//
//  Created by Lars Stegman on 29-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public enum Kind: String, Codable {
    case listing        = "Listing"
    case more           = "more"
    case liveUpdate     = "LiveUpdate"
    case comment        = "t1"
    case account        = "t2"
    case link           = "t3"
    case message        = "t4"
    case subreddit      = "t5"
    case award          = "t6"
    case promoCampaign  = "t7"
}

public protocol Kindable: Decodable {
    static var kind: Kind { get }
}

struct KindWrapper: Decodable {
    let kind: Kind
    let data: Kindable
    
    enum CodingKeys: String, CodingKey {
        case kind
        case data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .listing: data = try container.decode(Listing.self, forKey: .data)
        case .more: data = try container.decode(More.self, forKey: .data)
        case .comment: data = try container.decode(Comment.self, forKey: .data)
        case .account: data = try container.decode(Account.self, forKey: .data)
        case .link: data = try container.decode(Link.self, forKey: .data)
        case .subreddit: data = try container.decode(Subreddit.self, forKey: .data)
        default: throw DecodingError.typeMismatch(KindWrapper.self, DecodingError.Context(codingPath: [], debugDescription: "KindWrapper data is not implemented!"))
        }
    }
}
