//
//  ErrorResponse.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/5/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation
struct ErrorResponse: Codable {
    let status: Int
    let error: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return error
    }
}
