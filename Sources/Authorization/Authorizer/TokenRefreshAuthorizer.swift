//
//  TokenRefresh.swift
//  Helios
//
//  Created by Lars Stegman on 14-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

protocol TokenRefreshing: class {
    associatedtype RefreshToken: Token

    func refresh(token: RefreshToken)

    var delegate: TokenRefreshingDelegate? { get set }

    var refreshing: Bool { get }
}

protocol TokenRefreshingDelegate: class {
    func tokenRefreshing(didRefresh token: Token, with newToken: Token)

    func tokenRefreshing(failedToRefresh token: Token)
}
