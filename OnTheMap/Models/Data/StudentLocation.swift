//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/3/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation

struct StudentLocation: Codable {
    var objectId: String
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date?
    var updatedAt: Date?
}
