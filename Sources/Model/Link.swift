//
//  Link.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Link/*: Thing, Created, Votable */{
    public let id: String
    public static let kind = Kind.link

    // MARK: - Content data
    public let title: String
    public let contentUrl: URL
    public let permalink: String

    public let domain: URL
    public var selftext: String
    public let createdUtc: Date
    public let subreddit: String
    public let subredditId: String
    public let preview: Preview
    public var isEdited: Edited
    public let isSelf: Bool
    public let isOver18: Bool
    public let isSpoiler: Bool
    public var linkFlair: Flair?

    public let author: String?
    public let authorFlair: Flair?

    // MARK: - Community interaction data

    public var score: Int
    public var upvotes: Int
    public var downvotes: Int
    public var numberOfComments: Int
    public var distinguished: Distinguishment?
    public var isStickied: Bool
    public var isLocked: Bool

    // MARK: - User interaction data

    public var isHidden: Bool
    public var isRead: Bool
    public var liked: Vote
    public var isSaved: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingsKeys.self)
        id          = try container.decode(String.self, forKey: .id)
        title       = try container.decode(String.self, forKey: .title)
        contentUrl  = try container.decode(URL.self, forKey: .contentUrl)
        permalink   = try container.decode(String.self, forKey: .permalink)
        domain      = try container.decode(URL.self, forKey: .domain)
        selftext    = try container.decode(String.self, forKey: .selftext)
        createdUtc  = Date(timeIntervalSince1970: try container.decode(TimeInterval.self, forKey: .createdUtc))
        subreddit   = try container.decode(String.self, forKey: .subreddit)
        subredditId = try container.decode(String.self, forKey: .subredditId)
        preview     = try container.decode(Preview.self, forKey: .preview)
        isEdited    = try container.decode(Edited.self, forKey: .isEdited)
        isSelf      = try container.decode(Bool.self, forKey: .isSelf)
        isOver18    = try container.decode(Bool.self, forKey: .isOver18)
        isSpoiler   = try container.decode(Bool.self, forKey: .isSpoiler)
        linkFlair   = try LinkFlair(from: decoder)

        author      = try container.decode(String.self, forKey: .author)
        authorFlair = try AuthorFlair(from: decoder)

        score       = try container.decode(Int.self, forKey: .score)
        upvotes     = try container.decode(Int.self, forKey: .upvotes)
        downvotes   = try container.decode(Int.self, forKey: .downvotes)
        numberOfComments    = try container.decode(Int.self, forKey: .numberOfComments)
        distinguished       = try container.decode(Distinguishment.self, forKey: .distinguishment)
        isStickied  = try container.decode(Bool.self, forKey: .isStickied)
        isLocked    = try container.decode(Bool.self, forKey: .isLocked)

        isHidden    = try container.decode(Bool.self, forKey: .isHidden)
        isRead      = try container.decode(Bool.self, forKey: .isRead)
        liked       = try container.decode(Vote.self, forKey: .liked)
        isSaved     = try container.decode(Bool.self, forKey: .isSaved)
    }

    private enum CodingsKeys: String, CodingKey {
        case id
        case title
        case contentUrl = "url"
        case domain
        case score
        case upvotes = "ups"
        case downvotes = "downs"
        case author
        case isRead = "clicked"
        case isHidden = "hidden"
        case isSelf = "is_self"
        case liked = "likes"
        case isLocked = "locked"
        case isEdited = "edited"
        case numberOfComments = "num_comments"
        case isOver18 = "over_18"
        case isSpoiler = "spoiler"
        case permalink
        case isSaved = "saved"
        case selftext
        case subreddit
        case subredditId = "subreddit_id"
        case preview
        case isStickied = "stickied"
        case createdUtc = "created_utc"
        case distinguishment = "distinguished"
    }
}
