//
//  Account.swift
//  Helios
//
//  Created by Lars Stegman on 03-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Account: Created, Thing {
    public let id: String
    public static let kind = Kind.account
    public var fullname: String {
        return Account.kind.rawValue + "_" + id
    }

    public let name: String
    public let commentKarma: Int
    public let linkKarma: Int
    public let isOver18: Bool

    public let hasMail: Bool?
    public let hasModMail: Bool?
    public let hasVerifiedEmail: Bool
    public let inboxCount: Int?

    public let isFriend: Bool?
    public let isGilded: Bool
    public let isMod: Bool

    public let createdUtc: Date
}
