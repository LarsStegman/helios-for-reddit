//
//  SubmissionType.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public enum SubmissionType: String, Decodable {
    case link
    case `self`
    case any
}
