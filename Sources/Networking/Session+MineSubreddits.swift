//
//  Me.swift
//  Helios
//
//  Created by Lars Stegman on 25-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Session {

    private func mine(where: String, completionHandler: @escaping ResultHandler<Listing>) {
        guard authorized(for: .mysubreddits) else {
            completionHandler(nil, .missingScopeAuthorization(.mysubreddits))
            return
        }

        let url = URL(string: "subscriber/mine/\(`where`)", relativeTo: apiHost)!
        loadListing(from: url, completionHandler: completionHandler)
    }
   
    /// The subreddits to which the user is subscribed.
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    public func subscriptions(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "subscriber", completionHandler: completionHandler)
    }

    /// The subreddits where the authorized user is an approved submitter
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    public func contributor(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "contributor", completionHandler: completionHandler)
    }

    /// The subreddits where the authorized user is a moderator
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    public func moderator(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "moderator", completionHandler: completionHandler)
    }
}

