//
//  Comment.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation


/// A comment
public struct Comment: Created, Thing, Votable {
    public let id: String
    public let fullname: String
    public static let kind: Kind = .comment

    public let author: String
    public let authorFlair: Flair
    public let authorLink: String?
    public let distinguished: Distinguishment?

    public let linkId: String
    public let linkTitle: String?
    public let linkUrl: URL?
    public let parentId: String

    public let body: String
    public let htmlBody: String
    public let edited: Edited
    public var replies: [Thing]
    public let created: TimeInterval
    public let createdUtc: TimeInterval
    
    public private(set) var liked: Vote
    public private(set) var upvotes: Int
    public private(set) var downvotes: Int
    public private(set) var score: Int
    public let scoreHidden: Bool
    public let numberOfTimesGilded: Int
    public let moderationProperties: ModerationProperties?

    public var saved: Bool

    public let subreddit: String
    public let subredditId: String

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
