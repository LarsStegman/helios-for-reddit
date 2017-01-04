//
//  MoreParser.swift
//  Helios
//
//  Created by Lars Stegman on 04-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension More {
    init?(json json: [String: Any]) {
        guard let id = json["id"] as? String,
            let fullname = json["name"] as? String,
            let children = json["children"] as? [String] else {
                return nil
        }

        self = More(id: id, fullname: fullname, children: children)
    }
}
