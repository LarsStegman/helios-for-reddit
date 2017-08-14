//
//  Session+Listing.swift
//  Helios
//
//  Created by Lars Stegman on 04-02-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension HELSession {

    public func next(listing: Listing, parameters: ListingRequestParameters,
                     result: @escaping ResultHandler<Listing>, error: @escaping ErrorHandler) {
        guard let after = listing.after, let source = listing.source else {
            error(.noResult)
            return
        }

        let requestParameters = ListingRequestParameters(count: parameters.count, after: after,
                                                         limit: parameters.limit, show: parameters.show)
        loadListing(from: source, parameters: requestParameters, result: result, error: error)
    }

    public func previous(listing: Listing, parameters: ListingRequestParameters,
                         result: @escaping ResultHandler<Listing>, error: @escaping ErrorHandler) {
        guard let before = listing.before, let source = listing.source else {
            error(.noResult)
            return
        }

        let requestParameters = ListingRequestParameters(count: parameters.count, before: before,
                                                         limit: parameters.limit, show: parameters.show)
        loadListing(from: source, parameters: requestParameters, result: result, error: error)
    }

    public func loadListing(from: URL, parameters: ListingRequestParameters,
                            result: @escaping ResultHandler<Listing>, error: @escaping ErrorHandler) {
        var url = URLComponents(url: from, resolvingAgainstBaseURL: true)!
        var queryItems = url.queryItems ?? []
        queryItems.append(contentsOf: parameters.urlQueries)
        url.queryItems = queryItems
        queueTask(url: url.url!, result: { (wrapper: KindWrapper) in
            var resultListing = wrapper.data as! Listing
            resultListing.source = from
            result(resultListing)
        }, error: error)
    }

    public struct ListingRequestParameters {
        public let count: Int?
        public let before: String?
        public let after: String?
        public let limit: Int?
        public let show: Bool

        var urlQueries: [URLQueryItem] {
            var queries: [URLQueryItem] = []
            if let c = count, c > 0 {
                queries.append(URLQueryItem(name: "count", value: "\(c)"))
            }
            if let b = before {
                queries.append(URLQueryItem(name: "before", value: b))
            }
            if let a = after {
                queries.append(URLQueryItem(name: "after", value: a))
            }
            if let l = limit {
                queries.append(URLQueryItem(name: "limit", value: "\(l)"))
            }
            if show {
                queries.append(URLQueryItem(name: "show", value: nil))
            }
            return queries
        }

        public init(count: Int? = nil, before: String? = nil, after: String? = nil, limit: Int? = nil, show: Bool = false) {
            self.count = count
            self.before = before
            self.after = after
            self.limit = limit
            self.show = show
        }
    }
}


