//
//  Preview.swift
//  Helios
//
//  Created by Lars Stegman on 07-08-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

public struct Preview: Codable {
    let id: String
    let source: PreviewImage
    let resolutions: [PreviewImage]
    let variants: [PreviewImage.Variant: Preview]?

    private enum CodingKeys: String, CodingKey {
        case enabled
        case images
    }

    private enum ImagesCodingKeys: String, CodingKey {
        case id
        case source
        case resolutions
        case variants
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let enabled = try container.decode(Bool.self, forKey: .enabled)
        if !enabled {
            throw DecodingError.valueNotFound(PreviewImage.self,
                                              DecodingError.Context(codingPath: [CodingKeys.images], debugDescription: "Preview image is not enabled for the post."))
        }
        
        let imagesContainer = try container.nestedContainer(keyedBy: ImagesCodingKeys.self, forKey: .images)
        id = try imagesContainer.decode(String.self, forKey: .id)
        source = try imagesContainer.decode(PreviewImage.self, forKey: .source)
        resolutions = try imagesContainer.decode([PreviewImage].self, forKey: .resolutions)
        variants = try imagesContainer.decodeIfPresent([PreviewImage.Variant: Preview].self, forKey: .variants)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(true, forKey: .enabled)

        var images = container.nestedContainer(keyedBy: ImagesCodingKeys.self, forKey: .images)
        try images.encode(source, forKey: .source)
        try images.encode(resolutions, forKey: .resolutions)
        try images.encode(variants, forKey: .variants)
    }
}

public struct PreviewImage: Codable {

    public enum Variant: String, Codable {
        case gif
        case mp4
        case obfuscated
    }

    let url: URL
    let size: CGSize

    private enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
    }

    public init(from decoder: Decoder) throws {
        let container = try! decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
        size = CGSize(width: try container.decode(Double.self, forKey: .width),
                      height: try container.decode(Double.self, forKey: .height))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}


