//
//  Session+Identity.swift
//  Helios
//
//  Created by Lars Stegman on 29-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension HELSession {
    func identity(completion: @escaping ResultHandler<[String: Any]>) {
        guard authorized(for: .identity) else {
            completion(nil, .missingScopeAuthorization(.identity))
            return
        }

        let identityUrl = url(for: "api/v1/me")
        let identityTask = urlSession.dataTask(with:identityUrl) { (data, response, error) in
            guard let data = data, let dct = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]  else {
                completion(nil, .invalidResponse)
                return
            }

            completion(dct, nil)
        }
        queue(task: identityTask)
    }
}
