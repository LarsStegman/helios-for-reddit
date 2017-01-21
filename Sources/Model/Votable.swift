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
public enum Vote {
    case upvote
    case downvote
    case noVote

    /// - Parameter value: true == .upvote, false == .downvote, nil == .noVote
    init(value: Bool?) {
        if let value = value {
            self = value ? .upvote : .downvote
        } else {
            self = .noVote
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
        // TODO: Call reddit
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
        // TODO: Call reddit
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
        // TODO: Call reddit
    }
}
