//
//  Subreddit.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Subreddit: Thing, Equatable, Hashable {
    public let id: String
    public static let kind = Kind.subreddit

    public let name: String
    public let subtitle: String
    public let description: String
    public let numberOfSubscribers: Int?
    public var numberOfActiveAccounts: Int?
    public let isOver18: Bool
    public let relativeUrl: String
    public let header: Header?


    /// How long the comment score is hidden after submission in seconds.
    public let commentScoreHiddenDuration: TimeInterval

    public let trafficIsPublicallyAccessible: Bool

    public let allowedSubmissionTypes: SubmissionType
    public let type: SubredditType

    public let userData: UserMetaData

    /// Equality is determined by comparing the ids only.
    ///
    /// - Parameters:
    ///   - lhs: Left operand
    ///   - rhs: Right operand
    /// - Returns: Equality
    public static func ==(lhs: Subreddit, rhs: Subreddit) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int {
        return id.hashValue
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case subtitle = "title"
        case name = "display_name"
        case description
        case numberOfSubscribers = "subscribers"
        case numberOfActiveAccounts = "accounts_active"
        case isOver18 = "over18"
        case relativeUrl = "url"
        case commentScoreHiddenDuration = "comment_score_hide_mins"
        case trafficIsPublicallyAccessible = "public_traffic"
        case allowedSubmissionTypes = "submission_type"
        case type = "subreddit_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        description = try container.decode(String.self, forKey: .description)
        numberOfSubscribers = try container.decodeIfPresent(Int.self, forKey: .numberOfSubscribers)
        numberOfActiveAccounts = try container.decodeIfPresent(Int.self, forKey: .numberOfActiveAccounts)
        isOver18 = try container.decode(Bool.self, forKey: .isOver18)
        relativeUrl = try container.decode(String.self, forKey: .relativeUrl)
        header = try? Header(from: decoder)
        commentScoreHiddenDuration = try container.decode(TimeInterval.self, forKey: .commentScoreHiddenDuration)
        trafficIsPublicallyAccessible = try container.decode(Bool.self, forKey: .trafficIsPublicallyAccessible)
        allowedSubmissionTypes = try container.decode(SubmissionType.self, forKey: .allowedSubmissionTypes)
        type = try container.decode(SubredditType.self, forKey: .type)
        userData = try UserMetaData(from: decoder)
    }

    public struct UserMetaData: Decodable {
        public let banned: Bool
        public let contributing: Bool
        public let moderator: Bool
        public let muted: Bool
        public let subscriber: Bool
        public let favorite: Bool
        public let flairText: String?

        public static func ==(lhs: Subreddit.UserMetaData, rhs: Subreddit.UserMetaData) -> Bool {
            return lhs.banned == rhs.banned && lhs.contributing == rhs.contributing && lhs.moderator == rhs.moderator && lhs.muted == rhs.muted &&
                lhs.subscriber == rhs.subscriber
        }

        private enum CodingKeys: String, CodingKey {
            case banned = "user_is_banned"
            case contributing = "user_is_contributor"
            case moderator = "user_is_moderator"
            case muted = "user_is_muted"
            case subscriber = "user_is_subscriber"
            case flairText = "user_flair_text"
            case subredditHasFlair = "user_can_flair_in_sr"
            case favorite = "user_has_favorited"
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            banned = try container.decode(Bool.self, forKey: .banned)
            contributing = try container.decode(Bool.self, forKey: .contributing)
            moderator = try container.decode(Bool.self, forKey: .moderator)
            muted = try container.decode(Bool.self, forKey: .muted)
            subscriber = try container.decode(Bool.self, forKey: .subscriber)
            favorite = try container.decode(Bool.self, forKey: .favorite)
            if try container.decodeIfPresent(Bool.self, forKey: .subredditHasFlair) ?? false {
                flairText = try container.decode(String.self, forKey: .flairText)
            } else {
                flairText = nil
            }
        }
    }
}
