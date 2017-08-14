//
//  Me.swift
//  Helios
//
//  Created by Lars Stegman on 25-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension HELSession {

    public func subscriptions(result: @escaping ResultHandler<Listing>, error: @escaping ErrorHandler) {
        let subscriptionsUrl = URL(string: "subreddits/mine/subscriber", relativeTo: apiHost)!
        let listingParameters = HELSession.ListingRequestParameters()
        loadListing(from: subscriptionsUrl, parameters: listingParameters, result: result, error: error)
    }
}
