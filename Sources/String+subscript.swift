//
//  String+subscript.swift
//  Helios
//
//  Created by Lars Stegman on 19-01-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

extension String {
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index, limitedBy: self.endIndex)!
        return self[charIndex]
    }

    subscript (range: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: range.upperBound, limitedBy: self.endIndex)

        return self[startIndex..<endIndex!]
    }
}
