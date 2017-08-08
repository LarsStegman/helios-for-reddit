//
//  Votable.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol Votable {
    var upvotes: Int { get set }
    var downvotes: Int { get set }
    var liked: Vote { get set }
    var score: Int { get set }

    mutating func upvote()
    mutating func downvote()
    mutating func unvote()
}

/// A assessment of an item
///
/// - upvote: Like
/// - downvote: Not like
/// - noVote: No assessment
public enum Vote: Codable {
    case upvote
    case downvote
    case noVote

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer()
        if value.decodeNil() {
            self = .noVote
        } else {
            self = try value.decode(Bool.self) ? .upvote : .downvote
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .upvote: try container.encode(true)
        case .downvote: try container.encode(false)
        case .noVote: try container.encodeNil()
        }
    }
}

extension Votable {
    public mutating func upvote() {
        switch liked {
        case .upvote: return
        case .downvote:
            upvotes += 1
            downvotes -= 1
            score += 2
        case .noVote:
            upvotes += 1
            score += 1
        }
        liked = .upvote
    }

    public mutating func downvote() {
        switch liked {
        case .upvote:
            upvotes -= 1
            downvotes += 1
            score -= 2
        case .downvote: return
        case .noVote:
            downvotes += 1
            score -= 1
        }
        liked = .downvote
    }

    public mutating func unvote() {
        switch liked {
        case .upvote:
            upvotes -= 1
            score -= 1
        case .downvote:
            downvotes -= 1
            score += 1
        case .noVote: return
        }
        liked = .noVote
    }
}
