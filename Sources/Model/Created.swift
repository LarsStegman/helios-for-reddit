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

    /// The UTC time in epoch seconds
    var createdUtc: Date { get }
}
