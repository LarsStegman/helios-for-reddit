//
//  Me.swift
//  Helios
//
//  Created by Lars Stegman on 25-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension Session {

    private func mine(where: String,
                      completionHandler: @escaping (Listing?, SessionError?) -> Void) {
        guard authorized(for: .mysubreddits) else {
            completionHandler(nil, .missingScopeAuthorization(.mysubreddits))
            return
        }

        var urlComponents = apiHost
        urlComponents.path = "/subreddits/mine/\(`where`)"

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
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
        queueTask(task: task)
    }
   
    /// The subreddits to which the user is subscribed.
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    func subscriptions(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "subscriber", completionHandler: completionHandler)
    }

    /// The subreddits where the authorized user is an approved submitter
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    func contributor(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "contributor", completionHandler: completionHandler)
    }

    /// The subreddits where the authorized user is a moderator
    ///
    /// - Parameter completionHandler: Called with the result, or an error.
    func moderator(completionHandler: @escaping ResultHandler<Listing>) {
        mine(where: "moderator", completionHandler: completionHandler)
    }
}

