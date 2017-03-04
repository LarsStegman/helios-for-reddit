//
//  UserSubredditPermissions.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct UserSubredditRelations: Equatable {
    public let banned: Bool
    public let contributing: Bool
    public let moderator: Bool
    public let subscriber: Bool

    public static func ==(lhs: UserSubredditRelations, rhs: UserSubredditRelations) -> Bool {
        return lhs.banned == rhs.banned && lhs.contributing == rhs.contributing && lhs.moderator == rhs.moderator &&
            lhs.subscriber == rhs.subscriber
    }
}
