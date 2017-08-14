//
//  Edited.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public enum Edited: Codable {
    case unedited
    case edited(at: TimeInterval?)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolean = try? container.decode(Bool.self) {
            self = boolean ? .edited(at: nil) : .unedited
        } else {
            self = .edited(at: try container.decode(TimeInterval.self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .unedited: try container.encode(false)
        case .edited(at: nil): try container.encode(true)
        case .edited(at: let time): try container.encode(time)
        }
    }
}
