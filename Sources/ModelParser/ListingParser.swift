//
//  subscriptions.swift
//  Helios
//
//  Created by Lars Stegman on 31-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

extension Listing {
    init?(json json: [String: Any]) {
        guard let before = json["before"] as? String?,
            let after = json["after"] as? String?,
            let rawChildren = json["children"] as? [[String: Any]],
            let modhash = json["modhash"] as? String? else {
                return nil
        }

        let children = rawChildren.flatMap({ RedditParser.parseThing(object: $0) })
        self = Listing(before: before, after: after, modhash: modhash, children: children)
    }
}
