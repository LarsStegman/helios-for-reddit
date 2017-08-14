//
//  UserTokenTests.swift
//  HeliosTests
//
//  Created by Lars Stegman on 08-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import XCTest
@testable import Helios

class UserTokenTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUserTokenEncodingAndDecodingResultsInEquality() throws {
        let userToken = UserToken(username: "testName", accessToken: "access_this!", refreshToken: nil, scopes: [.identity], expiresAt: Date().addingTimeInterval(60))
        let tokenData = try PropertyListEncoder().encode(userToken)
        let decodedToken = try PropertyListDecoder().decode(UserToken.self, from: tokenData)
        XCTAssertEqual(userToken, decodedToken)
    }

    func testDecodeUserTokenFromJSONDictionary() throws {
        let userTokenDictionary = """
        {
            "access_token": "access_this!",
            "expires_in": 3600,
            "scope": "identity mysubreddits",
            "refresh_token": null,
            "username": "Lars34"
        }
        """.data(using: .utf8)!
        let token = try JSONDecoder().decode(UserToken.self, from: userTokenDictionary)
        let expectedToken = UserToken(username: "Lars34", accessToken: "access_this!", refreshToken: nil,
                                      scopes: [.identity, .mysubreddits], expiresAt: Date(timeIntervalSinceNow: 3600))
        XCTAssertEqual(token.username, expectedToken.username)
        XCTAssertEqual(token.accessToken, expectedToken.accessToken)
        XCTAssertEqual(token.refreshToken, expectedToken.refreshToken)
        XCTAssertEqual(token.scopes, expectedToken.scopes)
    }
}
