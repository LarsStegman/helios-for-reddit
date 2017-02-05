//
//  Session-Listing.swift
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
            completionHandler(nil, .noResult, true)
            return
        }

        var queries = [URLQueryItem(name: "after", value: "\(after)")]
        if let num = numberOfAlreadyLoadedComponents,
            num > 0 {
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
    public func previous(listing: Listing, numberOfAlreadyLoadedComponents: Int? = nil,
                         completionHandler: @escaping ResultHandler<Listing>) {
        guard let before = listing.before,
            let source = listing.source else {
            completionHandler(nil, .noResult, true)
            return
        }

        var queries = [URLQueryItem(name: "before", value: "\(before)")]
        if let num = numberOfAlreadyLoadedComponents {
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
    func loadListing(from url: URL, query: [URLQueryItem]? = nil,
                     completionHandler: @escaping ResultHandler<Listing>) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .invalidSource, true)
            return
        }

        components.queryItems = query
        let request = URLRequest(url: components.url!)
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let kindStr = json["kind"] as? String, Kind(rawValue: kindStr) == .listing,
                let listingData = json["data"] as? [String: Any],
                var result = Listing(json: listingData) else {

                completionHandler(nil, .invalidResponse, true)
                return
            }

            result.source = url
            completionHandler(result, nil, true)
        }
        queue(task: task)
    }
}
