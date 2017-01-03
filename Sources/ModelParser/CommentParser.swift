//
//  CommentParser.swift
//  Helios
//
//  Created by Lars Stegman on 31-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

extension Comment {

    /// Initializes a comment from a JSON dictionary. If the dictionary does not contain the 
    /// neccessary keys, this initializer will fail.
    ///
    /// - Parameters:
    ///   - json: The json dictionary describing a comment.
    convenience init?(json json: [String: Any]) {
        guard let id = json["id"] as? String,
            let fullname = json["name"] as? String,

            let author = json["author"] as? String,
            let authorFlairText = json["author_flair_text"] as? String?,
            let authorFlairCss = json["author_flair_css_class"] as? String?,
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

            let likedVal = json["liked"] as? Bool?,
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

        let authorFlair: Flair?
        if let authorText = authorFlairText {
            authorFlair = Flair(text: authorText, cssClass: authorFlairCss)
        }

        let distinguished: Distinguishment?
        if let text = distinguishmentText {
            distinguished = Distinguishment(rawValue: text)
        }

        let linkUrl: URL?
        if let text = linkUrlText {
            linkUrl = URL(string: text)
        }

        let edited: Edited
        if let editedTime = TimeInterval.init(editedText) {
            edited = .edited(at: editedTime)
        } else {
            edited = .notEdited
        }

        let replies = rawReplies.flatMap({ RedditParser.parse(object: $0) })
        let liked = Vote(value: likedVal)

        let moderationProperties: ModerationProperties?
        if let numReports = numberOfTimesReported {
            moderationProperties = ModerationProperties(approvedBy: approvedBy, bannedBy: bannedBy,
                                                        numberOfReports: numReports)
        }

        Comment(id: id, fullname: fullname, author: author, authorFlair: authorFlair,
                       authorLink: authorLink, distinguished: distinguished, linkId: linkId,
                       linkTitle: linkTitle, linkUrl: linkUrl, parentId: parentId, body: body,
                       htmlBody: htmlBody, edited: edited, replies: replies, created: created,
                       createdUtc: createdUtc, liked: liked, upvotes: upvotes, downvotes: downvotes,
                       score: score, scoreHidden: scoreHidden,
                       numberOfTimesGilded: numberOfTimesGilded,
                       moderationProperties: moderationProperties, saved: saved,
                       subreddit: subreddit, subredditId: subredditId)
    }
}
