//
//  Thumbnail.swift
//  Helios
//
//  Created by Lars Stegman on 02-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

/// A thumbnail for a link
///
/// - link: A link to a thumbnail
/// - _self: A self post
/// - image: The link is an image, but there is no thumbnail available
/// - _default: No thumbnail available
public enum Thumbnail {
    case link(url: URL)
    case `self`
    case image
    case `default`
    case spoiler

    init?(text: String) {
        switch text {
        case "default" : self = .default
        case "self" : self = .self
        case "image" : self = .image
        case "spoiler": self = .spoiler
        case _ where URL(string: text) != nil : self = .link(url: URL(string: text)!)
        default: return nil
        }
    }
}
