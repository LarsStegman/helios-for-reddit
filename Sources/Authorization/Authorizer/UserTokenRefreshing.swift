//
//  UserTokenRefreshing.swift
//  Helios
//
//  Created by Lars Stegman on 15-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

class UserTokenRefreshing: TokenRefreshing {

    typealias RefreshToken = UserToken

    weak var delegate: TokenRefreshingDelegate?
    private(set) var refreshing = false

    private var requestFactory = RedditTokenRequestFactory()

    /// Refreshes the provided user token. The token is stored in secure storage automatically.
    ///
    /// - Parameter token: The token to refresh.
    func refresh(token: RefreshToken) {
        guard !refreshing, let refresh = token.refreshToken else {
            delegate?.tokenRefreshing(failedToRefresh: token)
            return
        }

        refreshing = true
        NSLog("Refreshing token for %s", token.authorizationType.description)

        let request = requestFactory.createTokenRefreshingRequest(token: refresh)
        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, _, error) in
            self?.refreshing = false
            guard let data = data, let refreshedToken = try? JSONDecoder().decode(UserToken.self, from: data) else {
                self?.delegate?.tokenRefreshing(failedToRefresh: token)
                return
            }

            let newToken = UserToken(username: token.username, refreshToken: token.refreshToken, from: refreshedToken)
            TokenStore.saveTokenSecurely(token: newToken)
            self?.delegate?.tokenRefreshing(didRefresh: token, with: newToken)
        }).resume()
    }
}

fileprivate extension UserToken {
    init(username: String? = nil, accessToken: String? = nil, refreshToken: String? = nil, scopes: [Scope]? = nil,
         expiresAt: Date? = nil, from token: UserToken) {
        self.username = username ?? token.username
        self.accessToken = accessToken ?? token.accessToken
        self.refreshToken = refreshToken ?? token.refreshToken
        self.scopes = scopes ?? token.scopes
        self.expiresAt = expiresAt ?? token.expiresAt
    }
}
