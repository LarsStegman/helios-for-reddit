//
//  Subreddit.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Subreddit: Thing {
    public let id: String
    public let fullname: String
    public static let kind = Kind.subreddit

    public let title: String
    public let displayName: String
    public let description: String
    public let numberOfSubscribers: Int
    public var numberOfAccountsActive: Int
    public let isOver18: Bool
    public let url: URL
    public let header: Header?


    /// How long the comment score is hidden after submission in seconds.
    public let commentScoreHiddenDuration: TimeInterval
    /// json key: "description"
    public let sidebarText: String
    /// json key: "description_html"
    public let htmlSidebarText: String

    public let trafficIsPublicallyAccessible: Bool

    public let allowedSubmissionTypes: SubmissionType
    public let submitLinkLabel: String?
    public let submitTextLabel: String?
    public let type: SubredditType

    public let currentUserSubredditRelations: UserSubredditRelations
}
