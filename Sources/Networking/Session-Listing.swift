//
//  Session-Listing.swift
//  Helios
//
//  Created by Lars Stegman on 04-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Session {
    public func next(listing: Listing, numberOfAlreadyLoadedComponents: Int? = nil,
                     completionHandler: @escaping ResultHandler<Listing>) {
        guard let after = listing.after,
            let source = listing.source else {
            completionHandler(nil, .noResult)
            return
        }

        var queries = [URLQueryItem(name: "after", value: "\(after)")]

        if let num = numberOfAlreadyLoadedComponents {
            queries += [URLQueryItem(name: "count", value: "\(num)")]
        }

        loadListing(from: source, query: queries, completionHandler: completionHandler)
    }

    public func previous(listing: Listing, numberOfAlreadyLoadedComponents: Int? = nil,
                         completionHandler: @escaping ResultHandler<Listing>) {
        guard let before = listing.before,
            let source = listing.source else {
            completionHandler(nil, .noResult)
            return
        }

        var queries = [URLQueryItem(name: "before", value: "\(before)")]

        if let num = numberOfAlreadyLoadedComponents {
            queries += [URLQueryItem(name: "count", value: "\(num)")]
        }

        loadListing(from: source, query: queries, completionHandler: completionHandler)
    }

    func loadListing(from url: URL, query: [URLQueryItem]? = nil,
                     completionHandler: @escaping ResultHandler<Listing>) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completionHandler(nil, .invalidSource)
            return
        }

        if let queries = query {
            components.queryItems = queries
        }

        let request = URLRequest(url: components.url!)
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let kindStr = json["kind"] as? String, Kind(rawValue: kindStr) == .listing,
                let listingData = json["data"] as? [String: Any],
                let result = Listing(json: listingData) else {

                completionHandler(nil, .invalidResponse)
                return
            }

            completionHandler(result, nil)
        }
        queue(task: task)
    }
}
