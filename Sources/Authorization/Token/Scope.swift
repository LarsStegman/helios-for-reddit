//
//  Scope.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// The scope of the request authorization
/// See https://www.reddit.com/api/v1/scopes for a complete list of scopes.
public enum Scope: String, Codable {
    /// Spend my reddit gold creddits on giving gold to other users
    case creddits

    /// Add/remove users to approved submitter lists and ban/unban or mute/unmute users from
    /// subreddits I moderate.
    case modcontributors

    /// Access and manage modmail via mod.reddit.com.
    case modmail

    /// Manage the configuration, sidebar, and CSS of subreddits I moderate
    case modconfig

    /// Manage my subreddit subscriptions. Manage "friends" - users whose content I follow.
    case subscribe

    /// Read wiki pages through my account
    case wikiread

    /// Edit wiki pages on my behalf
    case wikiedit

    /// Submit and change my votes on comments and submissions
    case vote

    /// Access the list of subreddits I moderate, contribute to, and subscribe to.
    case mysubreddits

    /// Approve, remove, mark nsfw, and distinguish content in subreddits I moderate.
    case modposts

    /// Manage and assign flair in subreddits I moderate.
    case modflair

    /// Save and unsave comments and submissions
    case save

    /// Invite or remove other moderators from subreddits I moderate
    case modothers

    /// Access posts and comments through my account
    case read

    /// Access my inbox and send private messages to other users.
    case privatemessages

    /// Report content for rules violations. Hide & show individual submissions
    case report

    /// Access my reddit username and signup date
    case identity

    /// Manage settings and contributors of live threads I contribute to.
    case livemanage

    /// Update preferences and related account information. Will not have access to your email
    /// or password
    case account

    /// Access traffic stats in subreddits I moderate
    case modtraffic

    /// Edit and delete my comments and submissions.
    case edit

    /// Change editors and visibility of wiki pages in subreddits I moderate.
    case modwiki

    /// Accept invitations to moderate a subreddit. Remove myself as a moderator or contributor of
    /// subreddits I moderate or contribute to
    case modself

    /// Access my voting history and comments or submissions I've saved or hidden
    case history
    
    /// Select my subreddit flair. Change link flair on my submissions
    case flair


    /// Generates a list of scopes from a scope string. If a string is invalid, it is ignored.
    ///
    /// - Parameters:
    ///   - string: A string containing scopes
    ///   - separator: The separator with which the scopes are separated
    /// - Returns: An array of scopes.
    static func scopes(from string: String, separator: String = " ") -> [Scope] {
        return string.components(separatedBy: separator).flatMap({ return Scope(rawValue: $0) })
    }
}
