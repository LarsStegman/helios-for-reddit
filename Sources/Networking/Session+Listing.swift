//
//  Session+Listing.swift
//  Helios
//
//  Created by Lars Stegman on 04-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Session {

    /// Loads the next data slice.
    /// If there is no `after` in the listing, the completionHandler will be called with an 
    /// `SessionError.noResult` error.
    ///
    /// - Parameters:
    ///   - listing: The listing to load from
    ///   - numberOfAlreadyLoadedComponents: The number of already read items
    ///   - completionHandler: Called with the result or an error.
    public func next(listing: Listing, numberOfAlreadyLoadedComponents: Int? = nil,
                     completionHandler: @escaping ResultHandler<Listing>) {
        guard let after = listing.after,
            let source = listing.source else {
            completionHandler(nil, .noResult)
            return
        }

        var queries = [URLQueryItem(name: "after", value: "\(after)")]
        if let num = numberOfAlreadyLoadedComponents, num > 0 {
            queries += [URLQueryItem(name: "count", value: "\(num)")]
        }

        loadListing(from: source, query: queries, completionHandler: completionHandler)
    }

    /// Loads the previous data slice.
    /// If there is no `before` in the listing, the completionHandler will be called with an
    /// `SessionError.noResult` error.
    ///
    /// - Parameters:
    ///   - listing: The listing to load from
    ///   - numberOfAlreadyLoadedComponents: The number of already read items
    ///   - completionHandler: Called with the result or an error.
    public func previous(listing: Listing, numberOfAlreadyLoadedComponents: Int? = nil, completionHandler: @escaping ResultHandler<Listing>) {
        guard let before = listing.before,
            let source = listing.source else {
            completionHandler(nil, .noResult)
            return
        }

        var queries = [URLQueryItem(name: "before", value: "\(before)")]
        if let num = numberOfAlreadyLoadedComponents, num > 0 {
            queries += [URLQueryItem(name: "count", value: "\(num)")]
        }

        loadListing(from: source, query: queries, completionHandler: completionHandler)
    }

    /// Loads a listing from the provided url.
    ///
    /// - Parameters:
    ///   - url: The url to retrieve the listing from
    ///   - query: Query parameters for the listing, e.g. `before`
    ///   - completionHandler: Called with the result or an error. 
    ///       - Called with `.invalidResponse` error, if `url` does not return a listing.
    ///       - Called with `.invalidSource` if `url` contains invalid url components.
    func loadListing(from url: URL, query: [URLQueryItem]? = nil, completionHandler: @escaping ResultHandler<Listing>) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            completionHandler(nil, .invalidSource)
            return
        }

        components.queryItems = query
        let request = URLRequest(url: components.url!)
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data, let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let kindStr = json["kind"] as? String, Kind(rawValue: kindStr) == .listing,
                let listingData = json["data"] as? [String: Any],
                var result = Listing(json: listingData) else {

                completionHandler(nil, .invalidResponse)
                return
            }

            result.source = url
            completionHandler(result, nil)
        }
        queue(task: task)
    }

    /// Loads a listing with multiple pages.
    ///
    /// - Parameters:
    ///   - url: The url to load from.
    ///   - query: Extra wanted parameters, e.g. `limit`
    ///   - numberOfPages: The number of pages to load. If nil, all pages will be loaded.
    ///   - resultHandler: Called with the result, an error and a boolean indicating whether the loading has finished.
    ///
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    func loadListings(from url: URL, query: [URLQueryItem]? = nil, numberOfPages: Int? = 1,
                      resultHandler: @escaping IntermediateResultHandler<Listing>) {
        loadListing(from: url, query: query) { [weak self] (result, error) in
            guard let firstPage = result, error == nil else {
                resultHandler(nil, error, true)
                return
            }

            var loadNextPage: Bool
            var nextNumberOfPages: Int? = nil
            if let numberOfPages = numberOfPages {
                loadNextPage = firstPage.hasNext && numberOfPages > 1
                nextNumberOfPages = numberOfPages - 1
            } else {
                loadNextPage = firstPage.hasNext
            }
            loadNextPage = loadNextPage && self != nil

            resultHandler(firstPage, nil, !loadNextPage)
            if loadNextPage {
                self?.loadMore(first: firstPage,
                               numberOfAlreadyLoadedItems: firstPage.children.count,
                               numberOfPages: nextNumberOfPages,
                               intermediateResultHandler: resultHandler)
            }
        }
    }

    /// Keeps loading the next page until
    ///
    /// - Parameters:
    ///   - first: The first loaded listing page.
    ///   - numberOfPages: The maximum number of pages to retrieve. If nil, pages will be
    ///                     loaded indefinitely until none are left.
    ///   - numberOfAlreadyLoadedItems: The number of already loaded items
    ///   - numberOfItemsPerPage: 
    ///   - intermediateResultHandler: The closure that is called with intermediate results.
    ///
    /// - Warning: If you want to load all pages, but there are infinitely many pages, infinite recursion will occur.
    public func loadMore(first: Listing, numberOfAlreadyLoadedItems: Int = 0,
                         numberOfPages: Int?, intermediateResultHandler: @escaping IntermediateResultHandler<Listing>) {
        next(listing: first, numberOfAlreadyLoadedComponents: numberOfAlreadyLoadedItems) {
            [weak self] (result, nextPageError) in
            guard let nextPage = result, nextPageError == nil else {
                intermediateResultHandler(nil, nextPageError, true)
                return
            }

            var loadNextPage: Bool
            var nextNumberOfPages: Int? = nil
            if let numberOfPages = numberOfPages {
                loadNextPage = nextPage.hasNext && numberOfPages > 1
                nextNumberOfPages = numberOfPages - 1
            } else {
                loadNextPage = nextPage.hasNext
            }
            loadNextPage = loadNextPage && self != nil

            intermediateResultHandler(nextPage, nil, !loadNextPage)
            if loadNextPage {
                self?.loadMore(first: nextPage,
                               numberOfAlreadyLoadedItems: numberOfAlreadyLoadedItems + nextPage.children.count,
                               numberOfPages: nextNumberOfPages,
                               intermediateResultHandler: intermediateResultHandler)
            }
        }
    }

}
