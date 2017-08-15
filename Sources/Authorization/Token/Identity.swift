//
//  Identity.swift
//  Helios
//
//  Created by Lars Stegman on 08-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

struct Identity: Codable {
    let username: String

    private enum CodingKeys: String, CodingKey {
        case username = "name"
    }
}
