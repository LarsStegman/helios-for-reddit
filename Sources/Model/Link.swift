//
//  Link.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class Link: Created, Thing, Votable {
    public let id: String
    public let fullname: String
    public static let kind = Kind.link

    public let title: String
    public let url: URL
    public let domain: String
    public var score: Int
    public var upvotes: Int
    public var downvotes: Int

    public let author: String
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

    init(id: String, fullname: String, title: String, url: URL, domain: String, score: Int,
         upvotes: Int, downvotes: Int, author: String, authorFlair: Flair?, clicked: Bool,
         hidden: Bool, isSelf: Bool, liked: Vote, linkFlair: Flair?, locked: Bool,
         media: [String: Any]?, mediaEmbed: [String: Any]?, numberOfComments: Int, isOver18: Bool,
         permalink: String, saved: Bool, selftext: String, htmlSelftext: String, subreddit: String,
         subredditId: String, thumbnail: Thumbnail, edited: Edited, distinguished: Distinguishment?,
         stickied: Bool, created: TimeInterval, createdUtc: TimeInterval) {
        self.id = id
        self.fullname = fullname
        self.title = title
        self.url = url
        self.domain = domain
        self.score = score
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.author = author
        self.authorFlair = authorFlair
        self.clicked = clicked
        self.hidden = hidden
        self.isSelf = isSelf
        self.liked = liked
        self.linkFlair = linkFlair
        self.locked = locked
        self.media = media
        self.mediaEmbed = mediaEmbed
        self.numberOfComments = numberOfComments
        self.isOver18 = isOver18
        self.permalink = permalink
        self.saved = saved
        self.selftext = selftext
        self.htmlSelftext = htmlSelftext
        self.subreddit = subreddit
        self.subredditId = subredditId
        self.thumbnail = thumbnail
        self.edited = edited
        self.distinguished = distinguished
        self.stickied = stickied
        self.created = created
        self.createdUtc = createdUtc
    }

    public func upvote() {
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

    public func downvote() {
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

    public func unvote() {
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
