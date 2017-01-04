//
//  More.swift
//  Helios
//
//  Created by Lars Stegman on 04-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct More: Thing {
    public let id: String
    public let fullname: String
    public static let kind = Kind.more

    public let children: [String]
}
