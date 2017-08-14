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

public struct KindWrapper: Decodable {
    public let kind: Kind
    public let data: Kindable
    
    enum CodingKeys: String, CodingKey {
        case kind
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .listing: data = try container.decode(Listing.self, forKey: .data)
        case .subreddit: data = try container.decode(Subreddit.self, forKey: .data)
        default:
            throw DecodingError.typeMismatch(KindWrapper.self,
                                             .init(codingPath: decoder.codingPath + [CodingKeys.data],
                                                   debugDescription: "The data in the kind wrapper is of unknown type."))
        }

    }
}
