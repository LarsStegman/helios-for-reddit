//
//  ApplicationAuthorizer.swift
//  Helios
//
//  Created by Lars Stegman on 01-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public class ApplicationAuthorizer: Authorizer {
    public var delegate: AuthorizerDelegate?
    
    private var requestFactory = RedditTokenRequestFactory()
    private var tokenTask: URLSessionDataTask?

    public func start() {
        guard delegate != nil, let request = requestFactory.createApplicationTokenRequest() else {
            return
        }

        tokenTask = URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
            guard let d = data, let token = try? JSONDecoder().decode(ApplicationToken.self, from: d) else {
                self?.delegate?.authorizer(self!, authorizationFailedWith: .reddit)
                return
            }

            self?.storeToken(token: token)
            self?.tokenTask = nil
        }
        tokenTask?.resume()
    }
    
    public func cancel() {
        tokenTask?.cancel()
        tokenTask = nil
    }
    
    public func authorizationRequestResponse(url: URL) { }
    
    private func storeToken(token: ApplicationToken) {
        let stored = TokenStore.saveTokenSecurely(token: token)
        if stored {
            delegate?.authorizer(self, authorized: .application)
        } else {
            delegate?.authorizer(self, authorizationFailedWith: .internal)
        }
    }
}
