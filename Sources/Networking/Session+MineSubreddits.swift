//
//  Me.swift
//  Helios
//
//  Created by Lars Stegman on 25-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Session {

    /// The subreddits to which the user is subscribed.
    ///
    /// - Parameters:
    ///     - numberOfPages: The maximum number of pages to load, default: 1.
    ///                         If nil, all pages will be loaded until there are none left.
    ///     - resultHandler: Called with the result, or an error and a value indicating
    ///                       whether we have finished loading everything. If there is more to load,
    ///                       the boolean value is false and the completion handler will be called
    ///                       again until there is nothing left.
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    public func subscriptions(numberOfPages: Int? = 1,
                              resultHandler: @escaping IntermediateResultHandler<Listing>) {
        mine(where: "subscriber", numberOfPages: numberOfPages, resultHandler: resultHandler)
    }

    /// The subreddits where the authorized user is an approved submitter
    ///
    /// - Parameters:
    ///     - numberOfPages: The maximum number of pages to load, default: 1.
    ///                         If nil, all pages will be loaded until there are none left.
    ///     - resultHandler: Called with the result, or an error.
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    public func contributor(numberOfPages: Int? = 1,
                            resultHandler: @escaping IntermediateResultHandler<Listing>) {
        mine(where: "contributor", numberOfPages: numberOfPages, resultHandler: resultHandler)
    }

    /// The subreddits where the authorized user is a moderator
    ///
    /// - Parameters:
    ///     - numberOfPages: The maximum number of pages to load, default: 1.
    ///                         If nil, all pages will be loaded until there are none left.
    ///     - resultHandler: Called with the result, or an error.
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    public func moderator(numberOfPages: Int? = 1, resultHandler: @escaping IntermediateResultHandler<Listing>) {
        mine(where: "moderator", numberOfPages: numberOfPages, resultHandler: resultHandler)
    }

    /// Loads my subreddits
    ///
    /// - Parameters:
    ///   - where: The sub end point
    ///   - numberOfPages: The maximum number of pages to retrieve. If nil, pages will be
    ///                     loaded indefinitely until none are left.
    ///   - resultHandler: Called with the results, or an error and a boolean indicating whether 
    ///                     the fetching has finished.
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    private func mine(where: String, numberOfPages: Int?, resultHandler: @escaping IntermediateResultHandler<Listing>) {
        guard authorized(for: .mysubreddits) else {
            resultHandler(nil, .missingScopeAuthorization(.mysubreddits), true)
            return
        }

        let url = URL(string: "subreddits/mine/\(`where`)", relativeTo: apiHost)!
        loadListings(from: url, numberOfPages: numberOfPages, resultHandler: resultHandler)
    }
}
