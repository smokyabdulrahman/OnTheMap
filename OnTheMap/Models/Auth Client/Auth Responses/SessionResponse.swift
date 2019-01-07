//
//  SessionRespons.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/5/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation

struct SessionResponse: Codable {
    var session: Session
    var account: Account
}

struct Session: Codable {
    var id: String
}

struct Account: Codable {
    var registered: Bool
    var key: String
}
