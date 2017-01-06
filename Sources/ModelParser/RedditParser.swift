//
//  RedditParser.swift
//  Helios
//
//  Created by Lars Stegman on 31-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation


public class RedditParser {
    class func parse(object json: [String: Any]) -> RedditTyped? {
        guard let kindStr = json["kind"] as? String,
            let kind = Kind(rawValue: kindStr.lowercased()),
            let data = json["data"] as? [String: Any] else {
                return nil
        }

        switch kind {
        case .listing: return Listing(json: data)
        case .comment: return Comment(json: data)
        case .subreddit: return Subreddit(json: data)
        case .link: return Link(json: data)
        case .more: return More(json: data)
        default: return nil
        }

    }

    class func parseThing(object json: [String: Any]) -> Thing? {
        guard let kindStr = json["kind"] as? String,
            let kind = Kind(rawValue: kindStr.lowercased()),
            let data = json["data"] as? [String: Any] else {
                return nil
        }

        switch kind {
        case .comment: return Comment(json: data)
        case .subreddit: return Subreddit(json: data)
        case .link: return Link(json: data)
        case .more: return More(json: data)
        default: return nil
        }
    }
}
