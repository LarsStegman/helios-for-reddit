//
//  LinkTests.swift
//  Helios
//
//  Created by Lars Stegman on 05-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

import XCTest
@testable import Helios

class VotableTests: XCTestCase {

    private var testObject: Votable!

    override func setUp() {
        super.setUp()
        testObject = DefaultVotableImplementationTestObject()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testObject = nil
    }

    func testUpvoteAfterNoVote() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 0, downvotes: 0,
                                                            score: 0, liked: .noVote)

        testObject.upvote()
        XCTAssert(testObject.upvotes == 1)
        XCTAssert(testObject.downvotes == 0)
        XCTAssert(testObject.score == 1)
        XCTAssert(testObject.liked == .upvote)
    }

    func testUpvoteAfterDownvote() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 0, downvotes: 0,
                                                            score: 0, liked: .downvote)

        testObject.upvote()
        XCTAssert(testObject.upvotes == 1)
        XCTAssert(testObject.downvotes == -1)
        XCTAssert(testObject.score == 2)
        XCTAssert(testObject.liked == .upvote)
    }

    func testDownvoteAfterNoVote() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 0, downvotes: 0,
                                                            score: 0, liked: .noVote)

        testObject.downvote()
        XCTAssert(testObject.upvotes == 0)
        XCTAssert(testObject.downvotes == 1)
        XCTAssert(testObject.score == -1)
        XCTAssert(testObject.liked == .downvote)
    }

    func testDownvoteAfterUpvote() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 0, downvotes: 0,
                                                            score: 0, liked: .upvote)

        testObject.downvote()
        XCTAssert(testObject.upvotes == -1)
        XCTAssert(testObject.downvotes == 1)
        XCTAssert(testObject.score == -2)
        XCTAssert(testObject.liked == .downvote)
    }

    /// Tests whether
    func testUnvoteAfterUpvoted() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 1, downvotes: 0,
                                                            score: 1, liked: .upvote)

        testObject.unvote()
        XCTAssert(testObject.upvotes == 0)
        XCTAssert(testObject.downvotes == 0)
        XCTAssert(testObject.score == 0)
        XCTAssert(testObject.liked == .noVote)
    }

    func testUnvoteAfterDownvoted() {
        testObject = DefaultVotableImplementationTestObject(upvotes: 0, downvotes: 1,
                                                            score: -1, liked: .downvote)

        testObject.unvote()
        XCTAssert(testObject.upvotes == 0)
        XCTAssert(testObject.downvotes == 0)
        XCTAssert(testObject.score == 0)
        XCTAssert(testObject.liked == .noVote)
    }

    /// A test object to test the default votable implementation.
    private struct DefaultVotableImplementationTestObject: Votable {
        var upvotes: Int = 0
        var downvotes: Int = 0
        var score: Int = 0
        var liked: Vote = .noVote
    }
}
