//
//  Link.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Link: Created, Scored, Thing, Votable {
    public let id: String
    public let fullname: String
    public static let kind = Kind.link

    public let title: String
    public let url: URL
    public let domain: String
    public var score: Int
    public var upvotes: Int
    public var downvotes: Int

    public let author: String?
    public let authorFlair: Flair?

    public var clicked: Bool

    public var hidden: Bool
    public let isSelf: Bool
    public var liked: Vote
    public var linkFlair: Flair?
    public var locked: Bool
    public let media: [String: Any]?
    public let mediaEmbed: [String: Any]?
    public var numberOfComments: Int
    public let isOver18: Bool
    public let permalink: String
    public var saved: Bool

    public var selftext: String
    public var htmlSelftext: String
    public let subreddit: String
    public let subredditId: String
    public let thumbnail: Thumbnail


    public var edited: Edited
    public var distinguished: Distinguishment?
    public var stickied: Bool

    public let created: TimeInterval
    public let createdUtc: TimeInterval
}
