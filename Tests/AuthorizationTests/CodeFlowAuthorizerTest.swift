//
//  CodeFlowAuthorizerTest.swift
//  Helios
//
//  Created by Lars Stegman on 07-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import XCTest
@testable import Helios

class CodeFlowAuthorizerTest: XCTestCase {

    private struct DefaultAuthorizationFlowImplementation: AuthorizationFlow {
        var appCredentials: AppCredentials? = nil
        var responseType: String = "response"
        var authorizationURL: URLComponents = URLComponents(string: "www.reddit.com")!
        var compact: Bool = false

        var startAuthorizationStub: ((String) throws -> URL)? = nil
        func startAuthorization(state: String) throws -> URL {
            return try startAuthorizationStub?(state) ?? URL(string: "www.reddit.com")!
        }

        var handleResponseStub: (([URLQueryItem]) throws -> Void)? = nil
        func handleResponse(callbackURIParameters: [URLQueryItem]) throws {
            try handleResponseStub?(callbackURIParameters)
        }

        var retrieveAccessTokenStub: (((Error?) -> Void) throws -> Void)? = nil
        func retrieveAccessToken(finishAuthorization: @escaping (Error?) -> Void) throws {
            try retrieveAccessTokenStub?(finishAuthorization)
        }
    }

    private struct TestAppCredentials: AppCredentials {
        var clientId: String = ""
        var redirectUri: URL = URL(string: "www.reddit.com")!
        var authorizationDuration: AuthorizationDuration = .temporary
        var authorizationScopes: [Scope] = []
        var secret: String? = nil
        var userAgentString: String = "HeliosTesting"
        var localAppId: String = "helios-testing"
    }

    var testCodeFlowAuthorizer: CodeFlowAuthorizer!

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testCodeFlowAuthorizer = nil
    }

    func testStartAuthorizationMissingCredentials() {
        var authorizationFlow = DefaultAuthorizationFlowImplementation()
        authorizationFlow.startAuthorizationStub = { (_) in
            throw AuthorizationError.missingApplicationCredentials
        }

        testCodeFlowAuthorizer = CodeFlowAuthorizer(using: authorizationFlow)
        XCTAssertNil(testCodeFlowAuthorizer.startAuthorization())
    }


    /// Tests whether the authorization initialization fails correctly when the state 
    /// string contains illegal characters for a url query.
    func testStartAuthorizationIllegalCharacterInStateString() {
                var authorizationFlow = DefaultAuthorizationFlowImplementation()

        authorizationFlow.appCredentials = TestAppCredentials()
        authorizationFlow.startAuthorizationStub = { (_) in
            throw AuthorizationError.invalidStateString
        }

        testCodeFlowAuthorizer = CodeFlowAuthorizer(using: authorizationFlow)
        XCTAssertNil(testCodeFlowAuthorizer.startAuthorization())
    }

    func testStartAuthorizationGenericError() {
        var authorizationFlow = DefaultAuthorizationFlowImplementation()

        authorizationFlow.startAuthorizationStub = { (_) in
            throw LoginAuthorizerError.accessDenied
        }

        testCodeFlowAuthorizer = CodeFlowAuthorizer(using: authorizationFlow)
        XCTAssertNil(testCodeFlowAuthorizer.startAuthorization())
    }

    func testStartAuthorizationSuccessfully() {
        var authorizationFlow = DefaultAuthorizationFlowImplementation()
        let url = URL(string: "reddit.com")!
        authorizationFlow.startAuthorizationStub = { (_) in
            return url
        }

        testCodeFlowAuthorizer = CodeFlowAuthorizer(using: authorizationFlow)
        XCTAssertNotNil(testCodeFlowAuthorizer.startAuthorization())
    }



}
