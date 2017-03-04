//
//  SubredditSerialization.swift
//  Helios
//
//  Created by Lars Stegman on 03-03-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import XCTest
@testable import Helios

class SubredditSerializationTests: XCTestCase {

    private func testSubreddit(numberOfSubscribers: Int?, numberOfAccountsActive: Int?, header: Header?,
                               submitLinkLabel: String?, submitTextLabel: String?, submitText: String?) -> Subreddit {
        return Subreddit(id: "1", fullname: "t5_1", title: "Testing", displayName: "A Testing Subreddit",
                         description: "A Subreddit used for testing", numberOfSubscribers: numberOfSubscribers,
                         numberOfAccountsActive: numberOfAccountsActive, isOver18: true,
                         url: URL(string: "https://reddit.com/r/testing")!, header: header,
                         commentScoreHiddenDuration: 60, sidebarText: "A text in the sidebar",
                         trafficIsPublicallyAccessible: true, allowedSubmissionTypes: .self,
                         submitLinkLabel: submitLinkLabel, submitTextLabel: submitTextLabel, submitText: submitText,
                         type: SubredditType.public,
                         currentUserSubredditRelations: UserSubredditRelations(banned: false, contributing: true,
                                                                               moderator: false, subscriber: true))
    }

    func assertSubredditsEqual(lhs: Subreddit, rhs: Subreddit) {
        XCTAssertEqual(lhs.id, rhs.id)
        XCTAssertEqual(lhs.fullname, rhs.fullname)
        XCTAssertEqual(lhs.title, rhs.title)
        XCTAssertEqual(lhs.displayName, rhs.displayName)
        XCTAssertEqual(lhs.description, rhs.description)
        XCTAssertEqual(lhs.numberOfSubscribers, rhs.numberOfSubscribers)
        XCTAssertEqual(lhs.numberOfAccountsActive, rhs.numberOfAccountsActive)
        XCTAssertEqual(lhs.isOver18, rhs.isOver18)
        XCTAssertEqual(lhs.url, rhs.url)
        XCTAssertEqual(lhs.header, rhs.header)
        XCTAssertEqual(lhs.commentScoreHiddenDuration, rhs.commentScoreHiddenDuration)
        XCTAssertEqual(lhs.sidebarText, rhs.sidebarText)
        XCTAssertEqual(lhs.trafficIsPublicallyAccessible, rhs.trafficIsPublicallyAccessible)
        XCTAssertEqual(lhs.allowedSubmissionTypes, rhs.allowedSubmissionTypes)
        XCTAssertEqual(lhs.submitLinkLabel, rhs.submitLinkLabel)
        XCTAssertEqual(lhs.submitTextLabel, rhs.submitTextLabel)
        XCTAssertEqual(lhs.submitText, rhs.submitText)
        XCTAssertEqual(lhs.type, rhs.type)
        XCTAssertEqual(lhs.currentUserSubredditRelations, rhs.currentUserSubredditRelations)
    }

    /// Tests whether serializing a subreddit trough a propertylist is exact with all optional values nil.
    func testSerializationIsExactOptionalsNil() {
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: nil, header: nil,
                                      submitLinkLabel: nil, submitTextLabel: nil, submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactNumberOfSubscribersNotNil() {
        let subreddit = testSubreddit(numberOfSubscribers: 1, numberOfAccountsActive: nil, header: nil,
                                      submitLinkLabel: nil, submitTextLabel: nil, submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactNumberOfAccountActiveNotNil() {
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: 1, header: nil,
                                      submitLinkLabel: nil, submitTextLabel: nil, submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactHeaderNotNil() {
        let header = Header(imageUrl: URL(string: "https://imageProvider.com")!, size: .zero, title: "Header title")
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: nil, header: header,
                                      submitLinkLabel: nil, submitTextLabel: nil, submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactSubmitLinkLabelNotNil() {
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: nil, header: nil,
                                      submitLinkLabel: "Submit Link", submitTextLabel: nil, submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactSubmitTextLabelNotNil() {
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: nil, header: nil,
                                      submitLinkLabel: nil, submitTextLabel: "Make a submission", submitText: nil)

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }

    func testSerializationIsExactSubmitTextNotNil() {
        let subreddit = testSubreddit(numberOfSubscribers: nil, numberOfAccountsActive: nil, header: nil,
                                      submitLinkLabel: nil, submitTextLabel: nil, submitText: "Be sure to hit submit")

        let propertyListSubreddit = subreddit.propertyList
        guard let recreatedSubreddit = Subreddit(propertyList: propertyListSubreddit) else {
            XCTFail("Recreating the subreddit from a propertylist failed")
            return
        }

        assertSubredditsEqual(lhs: subreddit, rhs: recreatedSubreddit)
    }
}
