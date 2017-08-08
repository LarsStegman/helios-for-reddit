//
//  Thing.swift
//  Helios
//
//  Created by Lars Stegman on 29-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol Thing: Kindable {
    var id: String { get }
    var fullname: String { get }
    static var kind: Kind { get }
}

extension Thing {
    var fullname: String {
        return "\(Self.kind.rawValue)_\(id)"
    }
}
