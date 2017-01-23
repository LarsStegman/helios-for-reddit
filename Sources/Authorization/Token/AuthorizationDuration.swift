//
//  AuthorizationDuration.swift
//  Helios
//
//  Created by Lars Stegman on 17-12-16.
//  Copyright © 2016 Stegman. All rights reserved.
//

import Foundation

public enum AuthorizationDuration: String {

    /// Permanent access, unless the user revokes it.
    case permanent

    /// Temporary access, for example if you want to analyze the user's comments.
    case temporary
}
