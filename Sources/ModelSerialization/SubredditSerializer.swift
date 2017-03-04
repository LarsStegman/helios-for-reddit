//
//  SubredditSerializer.swift
//  Helios
//
//  Created by Lars Stegman on 02-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Subreddit {
    public var propertyList: PropertyList {
        return [
            "id": id,
            "fullname": fullname,
            "title": title,
            "displayName": displayName,
            "description": description,
            "numberOfSubscribers": numberOfSubscribers as Any,
            "numberOfAccountsActive": numberOfAccountsActive as Any,
            "isOver18": isOver18,
            "url": url.absoluteString,
            "header": header?.propertyList as Any,
            "commentScoreHiddenDuration": commentScoreHiddenDuration,
            "sidebarText": sidebarText,
            "trafficIsPublicallyAccessible": trafficIsPublicallyAccessible,
            "allowedSubmissionTypes": allowedSubmissionTypes.rawValue,
            "submitLinkLabel": submitLinkLabel as Any,
            "submitTextLabel": submitTextLabel as Any,
            "submitText": submitText as Any,
            "type": type.rawValue,
            "currentUserSubredditRelation": currentUserSubredditRelations.propertyList,
        ] as PropertyList
    }

    public init?(propertyList: PropertyList) {
        guard let dict = propertyList as? [String: PropertyList],
            let id = dict["id"] as? String,
            let fullname = dict["fullname"] as? String,
            let title = dict["title"] as? String,
            let displayName = dict["displayName"] as? String,
            let description = dict["description"] as? String,
            let isOver18 = dict["isOver18"] as? Bool,
            let urlStr = dict["url"] as? String,
            let url = URL(string: urlStr),
            let commentScoreHidden = dict["commentScoreHiddenDuration"] as? TimeInterval,
            let sidebarText = dict["sidebarText"] as? String,
            let trafficIsPublicallyAccessible = dict["trafficIsPublicallyAccessible"] as? Bool,
            let allowedSubmissionTypeStr = dict["allowedSubmissionTypes"] as? String,
            let allowedSubmissionType = SubmissionType(rawValue: allowedSubmissionTypeStr),
            let typeStr = dict["type"] as? String,
            let type = SubredditType(rawValue: typeStr),
            let currentUserSubredditRelationsData = dict["currentUserSubredditRelation"],
            let currentUserSubredditRelation = UserSubredditRelations(propertyList: currentUserSubredditRelationsData)
            else {
                return nil
        }

        var header: Header? = nil
        if let headerData = dict["header"] {
            header = Header(propertyList: headerData)
        }

        let numberOfSubscribers = dict["numberOfSubscribers"] as? Int
        let numberOfAccountsActive = dict["numberOfAccountsActive"] as? Int

        let submitLinkLabel = dict["submitLinkLabel"] as? String
        let submitTextLabel = dict["submitTextLabel"] as? String
        let submitText = dict["submitText"] as? String

        self = Subreddit(id: id, fullname: fullname, title: title, displayName: displayName, description: description,
                         numberOfSubscribers: numberOfSubscribers, numberOfAccountsActive: numberOfAccountsActive,
                         isOver18: isOver18, url: url, header: header, commentScoreHiddenDuration: commentScoreHidden,
                         sidebarText: sidebarText, trafficIsPublicallyAccessible: trafficIsPublicallyAccessible,
                         allowedSubmissionTypes: allowedSubmissionType, submitLinkLabel: submitLinkLabel,
                         submitTextLabel: submitTextLabel, submitText: submitText, type: type,
                         currentUserSubredditRelations: currentUserSubredditRelation)
    }
}

extension Header {
    var propertyList: PropertyList {
        return [
            "url": imageUrl.absoluteString,
            "size": size.dictionaryRepresentation,
            "title": title
        ] as PropertyList
    }

    init?(propertyList: PropertyList) {
        print("Stop")
        guard let dict = propertyList as? [String: PropertyList],
            let urlStr = dict["url"] as? String,
            let url = URL(string: urlStr),
            let sizeDict = dict["size"],
            let size = CGSize(dictionaryRepresentation: sizeDict as! CFDictionary),
            let title = dict["title"] as? String else {
                return nil
        }

        self = Header(imageUrl: url, size: size, title: title)
    }
}

extension UserSubredditRelations {
    var propertyList: PropertyList {
        return [
            "banned": banned,
            "contributing": contributing,
            "moderator": moderator,
            "subscriber": subscriber
        ] as PropertyList
    }

    init?(propertyList: PropertyList) {
        guard let dict = propertyList as? [String: Bool],
            let banned = dict["banned"],
            let contributing = dict["contributing"],
            let mod = dict["moderator"],
            let subscriber = dict["subscriber"] else {
                return nil
        }

        self = UserSubredditRelations(banned: banned, contributing: contributing, moderator: mod, subscriber: subscriber)
    }
}
