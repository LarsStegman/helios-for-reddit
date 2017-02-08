//
//  SubredditParser.swift
//  Helios
//
//  Created by Lars Stegman on 03-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Subreddit: RedditTyped {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let fullname = json["name"] as? String,

            let title = json["title"] as? String,
            let displayName = json["display_name"] as? String,
            let description = json["public_description"] as? String,
            let numberOfSubscribers = json["subscribers"] as? Int,
            let numberOfAccountsActive = json["accounts_active"] as? Int,
            let isOver18 = json["over18"] as? Bool,
            let urlText = json["url"] as? String,
            let url = URL(string: urlText),

            let commentScoreHiddenDuration = json["comment_score_hide_mins"] as? Double,
            let sidebarText = json["description"] as? String,
            let htmlSidebarText = json["description_html"] as? String,

            let trafficIsPublicallyAccessible = json["public_traffic"] as? Bool,

            let allowedSubmissionTypesStr = json["submission_type"] as? String,
            let submitLinkLabel = json["submit_link_label"] as? String,
            let submitTextLabel = json["submit_text_label"] as? String,
            let typeStr = json["subreddit_type"] as? String,

            let banned = json["user_is_banned"] as? Bool,
            let contributer = json["user_is_contributor"] as? Bool,
            let moderator = json["user_is_moderator"] as? Bool,
            let subscriber = json["user_is_subscriber"] as? Bool else {
                return nil
        }

        // Optionally available
        let headerImgText = json["header_img"] as? String
        let headerSize = json["header_size"] as? [Double]
        let headerTitle = json["header_title"] as? String

        var header: Header? = nil
        if let headerImgText = headerImgText, let url = URL(string: headerImgText),
            let size = headerSize, let title = headerTitle {
            let size = CGSize(width: size[0], height: size[1])
            header = Header(imageUrl: url, size: size, title: title)
        }

        let hiddenDuration = 60 * commentScoreHiddenDuration
        let allowedSubmissionTypes = SubmissionType(text: allowedSubmissionTypesStr) ?? .any
        let subredditType = SubredditType(rawValue: typeStr) ?? .public
        let userRelations = UserSubredditRelations(banned: banned, contributing: contributer,
                                                   moderator: moderator, subscriber: subscriber)

        self = Subreddit(id: id, fullname: fullname, title: title, displayName: displayName,
                  description: description, numberOfSubscribers: numberOfSubscribers,
                  numberOfAccountsActive: numberOfAccountsActive, isOver18: isOver18, url: url,
                  header: header, commentScoreHiddenDuration: hiddenDuration,
                  sidebarText: sidebarText, htmlSidebarText: htmlSidebarText,
                  trafficIsPublicallyAccessible: trafficIsPublicallyAccessible,
                  allowedSubmissionTypes: allowedSubmissionTypes, submitLinkLabel: submitLinkLabel,
                  submitTextLabel: submitTextLabel, type: subredditType,
                  currentUserSubredditRelations: userRelations)
    }
}
