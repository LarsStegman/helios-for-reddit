//
//  AuthorizationTest.swift
//  Helios
//
//  Created by Lars Stegman on 07-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import XCTest
@testable import Helios

class AuthorizationTest: XCTestCase {

    var testObject: Authorization!

    func testExample() {
        let expirationDate = Date(timeIntervalSinceNow: -60) // One minute ago
        testObject = Authorization(accessToken: "testToken", refreshToken: "testRefreshToken",
                                   tokenType: "bearer", scopes: [], expiresAt: expirationDate)
        XCTAssert(testObject.expired)
    }    
}
