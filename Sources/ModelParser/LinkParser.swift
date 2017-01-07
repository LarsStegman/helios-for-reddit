//
//  LinkParser.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Link: RedditTyped {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String,
            let fullname = json["name"] as? String,

            let title = json["title"] as? String,
            let urlStr = json["url"] as? String,
            let url = URL(string: urlStr),
            let domain = json["domain"] as? String,
            let score = json["score"] as? Int,
            let upvotes = json["ups"] as? Int,
            let downvotes = json["downs"] as? Int,

            let author = json["author"] as? String?,
            let authorFlairCss = json["author_flair_css_class"] as? String?,
            let authorFlairText = json["author_flair_text"] as? String?,

            let clicked = json["clicked"] as? Bool,

            let hidden = json["hidden"] as? Bool,
            let isSelf = json["is_self"] as? Bool,
            let likedVal = json["likes"] as? Bool?,
            let linkFlairCss = json["link_flair_csss_class"] as? String?,
            let linkFlairText = json["link_flair_text"] as? String?,
            let locked = json["locked"] as? Bool,
            let media = json["media"] as? [String: Any]?,
            let mediaEmbed = json["media_embed"] as? [String: Any]?,
            let numberOfComments = json["num_comments"] as? Int,
            let isOver18 = json["over_18"] as? Bool,
            let isSpoiler = json["spoiler"] as? Bool,
            let permalink = json["permalink"] as? String,
            let saved = json["saved"] as? Bool,

            let selftext = json["selftext"] as? String,
            let htmlSelftext = json["selftext_html"] as? String,
            let subreddit = json["subreddit"] as? String,
            let subredditId = json["subreddit_id"] as? String,
            let thumbnailStr = json["thumbnail"] as? String,


            let editedString = json["edited"] as? String,
            let distinguishedStr = json["distinguished"] as? String?,
            let stickied = json["stickied"] as? Bool,
            let created = json["created"] as? TimeInterval,
            let createdUtc = json["created_utc"] as? TimeInterval else {
                return nil
        }

        var authorFlair: Flair? = nil
        if let authorText = authorFlairText {
            authorFlair = Flair(text: authorText, cssClass: authorFlairCss)
        }

        let liked = Vote(value: likedVal)

        var linkFlair: Flair? = nil
        if let linkText = linkFlairText {
            linkFlair = Flair(text: linkText, cssClass: linkFlairCss)
        }

        let thumbnail = Thumbnail(text: thumbnailStr) ?? ._default
        let edited: Edited
        if let editedTime = TimeInterval.init(editedString) {
            edited = .edited(at: editedTime)
        } else {
            edited = .notEdited
        }

        var distinguished: Distinguishment? = nil
        if let text = distinguishedStr {
            distinguished = Distinguishment(rawValue: text)
        }

        self = Link(id: id, fullname: fullname, title: title, url: url, domain: domain, score: score,
             upvotes: upvotes, downvotes: downvotes, author: author, authorFlair: authorFlair,
             clicked: clicked, isHidden: hidden, isSelf: isSelf, liked: liked,
             linkFlair: linkFlair, isLocked: locked, media: media, mediaEmbed: mediaEmbed,
             numberOfComments: numberOfComments, isOver18: isOver18, isSpoiler: isSpoiler,
             permalink: permalink, isSaved: saved, selftext: selftext, htmlSelftext: htmlSelftext,
             subreddit: subreddit, subredditId: subredditId, thumbnail: thumbnail, edited: edited,
             distinguished: distinguished, isStickied: stickied, created: created,
             createdUtc: createdUtc)
    }
}
