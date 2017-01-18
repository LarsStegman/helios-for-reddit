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
    public let authorFlair: Flair?
    public let authorLink: String?
    public let distinguished: Distinguishment?

    public let linkId: String
    public let linkTitle: String?
    public let linkUrl: URL?
    public let parentId: String

    public let body: String
    public let htmlBody: String
    public let edited: Edited
    public var replies: Listing?
    public let createdUtc: Date
    
    public var liked: Vote
    public var upvotes: Int
    public var downvotes: Int
    public var score: Int
    public let scoreHidden: Bool
    public let numberOfTimesGilded: Int
    public let moderationProperties: ModerationProperties?

    public var saved: Bool

    public let subreddit: String
    public let subredditId: String
}
