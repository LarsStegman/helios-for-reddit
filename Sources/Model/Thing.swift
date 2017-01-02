//
//  Thing.swift
//  Helios
//
//  Created by Lars Stegman on 29-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol Thing {
    var id: String { get }
    var fullname: String { get }
    static var kind: Kind { get }
}

