//
//  AuthorizerRequestFactory.swift
//  Helios
//
//  Created by Lars Stegman on 29-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

protocol AuthorizerRequestFactory {
    func createTokenRetrievalRequest(context: AuthorizationContext) -> URLRequest?

    func createTokenRefreshingRequest(token: String) -> URLRequest

    func createTokenRevokingRequest(token: String, type: TokenType) -> URLRequest?

    func createApplicationTokenRequest() -> URLRequest?
}

protocol AuthorizationCredentials {
    var clientId: String { get }
    var userAgentString: String { get }
    var redirectUri: URL { get }
    var uuid: UUID { get }
}

extension Credentials: AuthorizationCredentials {}

enum TokenType: String {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
}

struct RedditTokenRequestFactory: AuthorizerRequestFactory {

    var credentials: AuthorizationCredentials = Credentials.sharedInstance
    var redditAccessTokenURL = URL(string: "https://www.reddit.com/api/v1/access_token")!
    var redditRevokeAccessTokenURL = URL(string: "https://www.reddit.com/api/v1/revoke_token")!

    private func createBasicRedditTokenRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(credentials.userAgentString, forHTTPHeaderField: "User-Agent")
        let authData = "\(credentials.clientId):".data(using: .utf8)!.base64EncodedString()
        let authStr = "Basic \(authData)"
        request.addValue(authStr, forHTTPHeaderField: "Authorization")

        return request
    }

    func createTokenRetrievalRequest(context: AuthorizationContext) -> URLRequest? {
        guard let code = context.receivedCode else {
            return nil
        }

        var request = createBasicRedditTokenRequest(url: redditAccessTokenURL)
        let postContent = "grant_type=authorization_code&code=\(code)&redirect_uri=\(credentials.redirectUri.absoluteString)"
        request.httpBody = postContent.data(using: .utf8)
        return request
    }

    func createTokenRefreshingRequest(token: String) -> URLRequest {
        var request = createBasicRedditTokenRequest(url: redditAccessTokenURL)

        let postContent = "grant_type=refresh_token&refresh_token=\(token)"
        request.httpBody = postContent.data(using: .utf8)
        return request
    }

    func createTokenRevokingRequest(token: String, type: TokenType) -> URLRequest? {
        var request = createBasicRedditTokenRequest(url: redditRevokeAccessTokenURL)

        request.httpMethod = "POST"
        request.httpBody = "token=\(token)&token_type_hint=\(type.rawValue)".data(using: .utf8)

        return request
    }

    func createApplicationTokenRequest() -> URLRequest? {
        var request = createBasicRedditTokenRequest(url: redditAccessTokenURL)

        let postContent = "grant_type=\(GrantType.installedClient.rawValue)&device_id=\(credentials.uuid.uuidString)"
        request.httpBody = postContent.data(using: .utf8)

        return request
    }
}
