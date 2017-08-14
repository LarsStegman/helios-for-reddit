//
//  Comment.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation


/// A comment
public struct Comment /*: Created, Thing, Votable*/ {
    public let id: String
    public static let kind: Kind = .comment

    public let author: AuthorMetaData
    public let distinguished: Distinguishment?

    public let linkData: LinkMetaData?

    public let parentId: String
    public let body: String
    public let edited: Edited
    public var replies: Listing?
    public let createdUtc: Date
    
    public var liked: Vote
    public var score: Score
    public let moderationProperties: ModerationProperties?

    public var saved: Bool

    public let subredditData: SubredditMetaData

//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//    }
//
//    private enum CodingKeys: String, CodingKey {
//        case id
//        case author
//        case distinguished
//        case
//    }

    public struct LinkMetaData: Decodable {
        public let fullname: String
        public let title: String
        public let url: URL
        public let author: String

        private enum CodingKeys: String, CodingKey {
            case fullname = "link_id"
            case title = "link_title"
            case url = "link_permalink"
            case author = "link_author"
        }
    }

    public struct AuthorMetaData: Decodable {
        public let name: String
        public let flairText: String?

        private enum CodingKeys: String, CodingKey {
            case name = "link_author"
            case flairText = "author_flair_text"
        }
    }

    public struct SubredditMetaData: Decodable {
        public let name: String
        public let fullname: String

        private enum CodingKeys: String, CodingKey {
            case name = "subreddit"
            case fullname = "subreddit_id"
        }
    }
}


