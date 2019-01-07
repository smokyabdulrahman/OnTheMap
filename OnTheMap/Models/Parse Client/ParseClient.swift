//
//  ParseClient.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/4/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation

class ParseClient {
    static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
    enum Endpoints {
        static let base = "https://parse.udacity.com/parse/classes"
        
        case StudentsLocations
        case StudentLocation(String)
        case UpdateStudentLocation(String)
        
        var stringValue: String {
            switch self {
            case .StudentsLocations:
                return Endpoints.base + "/StudentLocation"
            case .StudentLocation(let uniqueKey):
                return Endpoints.base + "/StudentLocation?where=" + ("{\"uniqueKey\":\"\(uniqueKey)\"}".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            case .UpdateStudentLocation(let objectId):
                return Endpoints.base + "/StudentLocation/" + (objectId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    static func getDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })
        
        return decoder
    }
    
    static func taskForGET<ResponseType: Codable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let request = buildCommonRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
//            print(String(data: data, encoding: .utf8)!)
            print("lol")
            let decoder = getDecoder()
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        task.resume()
    }
    
    static func taskForPOST<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request = buildCommonRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try! encoder.encode(body)
        
        print(String(data: request.httpBody!, encoding: .utf8)!)
        print(request.debugDescription)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            print(String(data: data, encoding: .utf8)!)
            let decoder = getDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data) as Error
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    static func taskForPUT<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request = buildCommonRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
    }
    
    static func getStudentsLocations(completionHandler: @escaping ([StudentLocation], Error?) -> Void){
        taskForGET(url: Endpoints.StudentsLocations.url, responseType: StudentsLocationsResponse.self) { (response, error) in
            if let response = response {
                let results = response.results.filter({ (studentLocation) -> Bool in
                    if studentLocation.firstName != nil {
                        return true
                    }
                    return false
                })
                completionHandler(results, nil)
            } else {
                completionHandler([], error)
            }
        }
    }
    
    static func postStudentLocation(_ studentLocation: StudentLocationBody, completionHandler: @escaping (StudentLocation?, Error?) -> Void){
        taskForPOST(url: Endpoints.StudentsLocations.url, responseType: StudentLocation.self, body: studentLocation) { (studentLocation, error) in
            guard let studentLocation = studentLocation else {
                completionHandler(nil, error)
                return
            }
            completionHandler(studentLocation, error)
        }
    }
    
    static func buildCommonRequest(url: URL) -> URLRequest{
        var request = URLRequest(url: url)
        request.addValue(ParseClient.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(ParseClient.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
}

enum DateError: String, Error {
    case invalidDate
}
