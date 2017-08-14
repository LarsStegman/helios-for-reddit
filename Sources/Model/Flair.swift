//
//  Flair.swift
//  Helios
//
//  Created by Lars Stegman on 30-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public protocol Flair {
    var text: String { get }
    var cssClass: String? { get }
}

public struct AuthorFlair: Flair, Codable {
    public let text: String
    public let cssClass: String?

    enum CodingKeys: String, CodingKey {
        case text = "author_flair_text"
        case cssClass = "author_flair_css_class"
    }
}

public struct LinkFlair: Flair, Codable {
    public let text: String
    public let cssClass: String?

    enum CodingKeys: String, CodingKey {
        case text = "link_flair_text"
        case cssClass = "link_flair_css_class"
    }
}
