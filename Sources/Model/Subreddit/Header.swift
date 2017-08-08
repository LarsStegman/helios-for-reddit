//
//  Header.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Header: Decodable, Equatable {
    public let imageUrl: URL
    public let size: CGSize
    public let title: String

    public static func ==(lhs: Header, rhs: Header) -> Bool {
        return lhs.imageUrl == rhs.imageUrl && lhs.size == rhs.size && lhs.title == rhs.title
    }

    private enum CodingKeys: String, CodingKey {
        case imageUrl = "header_img"
        case size = "header_size"
        case title = "header_title"
    }
}
