//
//  Created.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

/// An item that has been created at some time
public protocol Created {
    /// The local time in epoch seconds
    var created: TimeInterval { get }

    /// The UTC time in epoch seconds
    var createdUtc: TimeInterval { get }
}
