//
//  Score.swift
//  Helios
//
//  Created by Lars Stegman on 08-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Score {
    public var upvotes: Int
    public var downvotes: Int
    public var score: Int
    public var likedRatio: Double?
    public var scoreHidden: Bool
    public let numberOfTimesGilded: Int

    private enum UserCodingKeys: String, CodingKey {
        case upvotes = "ups"
        case downvotes = "downs"
        case score
        case likedRatio = "upvote_ratio"
        case scoreHidden = "hide_score"
        case numberOfTimesGilded = "gilded"
    }

    private enum LinkCodingKeys: String, CodingKey {
        case upvotes = "ups"
        case downvotes = "downs"
        case score
        case likedRatio = "upvote_ratio"
        case scoreHidden = "score_hidden"
        case numberOfTimesGilded = "gilded"
    }

    public init(userScoreFrom decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: UserCodingKeys.self)
        upvotes = try container.decode(Int.self, forKey: .upvotes)
        downvotes = try container.decode(Int.self, forKey: .downvotes)
        score = try container.decode(Int.self, forKey: .score)
        likedRatio = try container.decodeIfPresent(Double.self, forKey: .likedRatio)
        scoreHidden = try container.decode(Bool.self, forKey: .scoreHidden)
        numberOfTimesGilded = try container.decode(Int.self, forKey: .numberOfTimesGilded)
    }

    public init(linkScoreFrom decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LinkCodingKeys.self)
        upvotes = try container.decode(Int.self, forKey: .upvotes)
        downvotes = try container.decode(Int.self, forKey: .downvotes)
        score = try container.decode(Int.self, forKey: .score)
        likedRatio = try container.decodeIfPresent(Double.self, forKey: .likedRatio)
        scoreHidden = try container.decode(Bool.self, forKey: .scoreHidden)
        numberOfTimesGilded = try container.decode(Int.self, forKey: .numberOfTimesGilded)
    }
}
