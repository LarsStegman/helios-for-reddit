//
//  Subreddit.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class Subreddit: Thing {
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

    public init(id: String, fullname: String, title: String, displayName: String,
                description: String, numberOfSubscribers: Int, numberOfAccountsActive: Int,
                isOver18: Bool, url: URL, header: Header?, commentScoreHiddenDuration: TimeInterval,
                sidebarText: String, htmlSidebarText: String, trafficIsPublicallyAccessible: Bool,
                allowedSubmissionTypes: SubmissionType, submitLinkLabel: String?,
                submitTextLabel: String?, type: SubredditType,
                currentUserSubredditRelations: UserSubredditRelations) {
        self.id = id
        self.fullname = fullname

        self.title = title
        self.displayName = displayName
        self.description = description
        self.numberOfSubscribers = numberOfSubscribers
        self.numberOfAccountsActive = numberOfAccountsActive
        self.isOver18 = isOver18
        self.url = url
        self.header = header

        self.commentScoreHiddenDuration = commentScoreHiddenDuration
        self.sidebarText = sidebarText
        self.htmlSidebarText = htmlSidebarText

        self.trafficIsPublicallyAccessible = trafficIsPublicallyAccessible

        self.allowedSubmissionTypes = allowedSubmissionTypes
        self.submitLinkLabel = submitLinkLabel
        self.submitTextLabel = submitTextLabel
        self.type = type
    }
}
