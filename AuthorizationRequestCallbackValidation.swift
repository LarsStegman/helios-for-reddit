//
//  RedditCallbackValidation.swift
//  Helios
//
//  Created by Lars Stegman on 27-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

protocol OAuthCallbackParameters {
    var redirectUri: URL { get }
    var sentState: String { get }
}

extension AuthorizationContext: OAuthCallbackParameters {}

protocol OAuthCallbackValidation {
    func validate(url: URL, parameters: OAuthCallbackParameters) throws -> AuthorizationRequestResponse
}

struct RedditAuthorizationCallbackValidation: OAuthCallbackValidation {
    func validate(url: URL, parameters: OAuthCallbackParameters) throws -> AuthorizationRequestResponse {
        if url.host != parameters.redirectUri.host {
            throw LoginAuthorizerError.internal
        }

        guard let queries = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            throw LoginAuthorizerError.internal
        }

        guard let response = AuthorizationRequestResponse(from: queries) else {
            throw LoginAuthorizerError.reddit
        }

        return response
    }
}
