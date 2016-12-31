//
//  CommentParser.swift
//  Helios
//
//  Created by Lars Stegman on 31-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

extension Comment {
    init?(json json: [String: Any]) {
        guard let id = json["id"] as? String,
            let fullname = json["name"] as? String,

            let author = json["author"] as? String,
            let authorFlairText = json["author_flair_text"] as? String,
            let authorFlairCss = json["author_flair_css_class"] as? String,
            let authorLink = json["link_author"] as? String?,
            let distinguishmentText = json["distinguished"] as? String?,

            let linkId = json["link_id"] as? String,
            let linkTitle = json["link_title"] as? String?,
            let linkUrlText = json["link_url"] as? String?,
            let parentId = json["parent_id"] as? String,

            let body = json["body"] as? String,
            let htmlBody = json["body_html"] as? String,
            let editedText = json["edited"] as? String,
            let rawReplies = json["replies"] as? [Any],
            let created = json["created"] as? TimeInterval,
            let createdUtc = json["created_utc"] as? TimeInterval,

            let liked = json["liked"] as? Bool?,
            let upvotes = json["ups"] as? Int,
            let downvotes = json["downs"] as? Int,
            let score = json["score"] as? Int,
            let scoreHidden = json["score_hidden"] as? Bool,
            let numberOfTimesGilded = json["gilded"] as? Int,
            let approvedBy = json["approved_by"] as? String?,
            let bannedBy = json["banned_by"] as? String?,
            let numberOfTimesReported = json["num_reports"] as? Int?,
            let saved = json["saved"] as? Bool,

            let subreddit = json["subreddit"] as? String,
            let subredditId = json["subreddit_id"] as? String else {
                return nil
        }

        self.id = id
        self.fullname = fullname
        self.author = author
        self.authorFlair = Flair(text: authorFlairText, cssClass: authorFlairCss)
        self.authorLink = authorLink
        if let text = distinguishmentText {
            self.distinguished = Distinguishment(text: text)
        }

        self.linkId = linkId
        self.linkTitle = linkTitle
        if let text = linkUrlText {
            self.linkUrl = URL(string: text)
        }

        self.parentId = parentId
        self.body = body
        self.htmlBody = htmlBody
        if let edited = TimeInterval.init(editedText) {
            self.edited = .edited(at: edited)
        } else {
            self.edited = .notEdited
        }

        self.replies = rawReplies.map({ RedditParser.parse(object: $0) })
        self.created = created
        self.createdUtc = createdUtc
        self.liked = Vote(value: liked)
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.score = score
        self.scoreHidden = scoreHidden
        self.numberOfTimesGilded = numberOfTimesGilded
        if let numReports = numberOfTimesReported {
            self.moderationProperties = ModerationProperties(approvedBy: approvedBy, bannedBy: bannedBy, numberOfReports: numReports)
        }

        self.saved = saved
        self.subreddit = subreddit
        self.subredditId = subredditId        
    }
}
