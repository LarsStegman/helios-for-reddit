//
//  AuthorizationFlowKind.swift
//  Helios
//
//  Created by Lars Stegman on 27-07-17.
//  Copyright © 2017 Stegman. All rights reserved.
//

import Foundation

enum AuthorizationFlowType: String {
    case code
    case implicit = "token"
}
