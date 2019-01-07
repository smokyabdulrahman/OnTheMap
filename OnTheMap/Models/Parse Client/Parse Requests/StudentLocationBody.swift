//
//  StudentLocationBody.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/10/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation
struct StudentLocationBody: Codable {
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
}
