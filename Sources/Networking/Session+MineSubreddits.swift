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
    ///     - maximumNumberOfPages: The maximum number of pages to load, default: 1.
    ///     - resultHandler: Called with the result, or an error and a value indicating
    ///                       whether we have finished loading everything. If there is more to load,
    ///                       the boolean value is false and the completion handler will be called
    ///                       again until there is nothing left.
    public func subscriptions(maximumNumberOfPages: Int = 1,
                              resultHandler: @escaping ResultHandler<Listing>) {
        mine(where: "subscriber", maximumNumberOfPages: maximumNumberOfPages,
             resultHandler: resultHandler)
    }

    /// The subreddits where the authorized user is an approved submitter
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    public func contributor(maximumNumberOfPages: Int = 1,
                            resultHandler: @escaping ResultHandler<Listing>) {
        mine(where: "contributor", maximumNumberOfPages: maximumNumberOfPages,
             resultHandler: resultHandler)
    }

    /// The subreddits where the authorized user is a moderator
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    public func moderator(maximumNumberOfPages: Int = 1,
                          resultHandler: @escaping ResultHandler<Listing>) {
        mine(where: "moderator", maximumNumberOfPages: maximumNumberOfPages,
             resultHandler: resultHandler)
    }

    /// Loads my subreddits
    ///
    /// - Parameters:
    ///   - where: The sub end point
    ///   - maximumNumberOfPages: The maximum number of pages to retrieve
    ///   - resultHandler: Called with the results, or an error and a boolean indicating whether 
    ///         the fetching has finished.
    private func mine(where: String, maximumNumberOfPages: Int,
                      resultHandler: @escaping ResultHandler<Listing>) {
        guard authorized(for: .mysubreddits) else {
            resultHandler(nil, .missingScopeAuthorization(.mysubreddits), true)
            return
        }

        let url = URL(string: "subscriber/mine/\(`where`)", relativeTo: apiHost)!
        loadListing(from: url) { [weak self] (result, error, _) in
            guard let firstPage = result, error == nil else {
                resultHandler(nil, error, true)
                return
            }

            let loadNextPage = firstPage.hasNext && maximumNumberOfPages > 1
            resultHandler(firstPage, nil, !loadNextPage)
            if loadNextPage {
                self?.loadMore(first: firstPage,
                               numberOfAlreadyLoadedItems: firstPage.children.count,
                               maximumNumberOfPages: maximumNumberOfPages - 1,
                               intermediateResultHandler: resultHandler)
            }
        }
    }

    /// Keeps loading the next page until
    ///
    /// - Parameters:
    ///   - first: The first loaded listing page.
    ///   - numberOfAlreadyLoadedItems: The number of already loaded items
    ///   - intermediateResultHandler: The closure that is called with intermediate results.
    private func loadMore(first: Listing, numberOfAlreadyLoadedItems: Int = 0,
                          maximumNumberOfPages: Int, intermediateResultHandler:
                            @escaping (Listing?, SessionError?, Bool) -> Void) {
        next(listing: first) { [weak self] (result, nextPageError, _) in
            guard let nextPage = result, nextPageError == nil else {
                intermediateResultHandler(nil, nextPageError, true)
                return
            }

            let loadNextPage = nextPage.hasNext && maximumNumberOfPages > 1
            intermediateResultHandler(nextPage, nil, !loadNextPage)
            if loadNextPage {
                self?.loadMore(first: nextPage,
                               numberOfAlreadyLoadedItems:
                                    numberOfAlreadyLoadedItems + nextPage.children.count,
                               maximumNumberOfPages: maximumNumberOfPages - 1,
                               intermediateResultHandler: intermediateResultHandler)
            }
        }
    }
}

