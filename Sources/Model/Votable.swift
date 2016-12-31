//
//  Votable.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol Votable {
    var upvotes: Int { get }
    var downvotes: Int { get }
    var liked: Vote { get }

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

    init(value: Bool?) {
        if let value = value {
            self = value ? .upvote : .downvote
        } else {
            self = .noVote
        }
    }
}


