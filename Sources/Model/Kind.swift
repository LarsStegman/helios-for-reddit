//
//  Kind.swift
//  Helios
//
//  Created by Lars Stegman on 29-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public enum Kind: String {
    case listing
    case more
    case comment        = "t1"
    case account        = "t2"
    case link           = "t3"
    case message        = "t4"
    case subreddit      = "t5"
    case award          = "t6"
    case promoCampaign  = "t7"
}
