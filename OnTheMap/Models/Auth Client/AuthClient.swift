//
//  AuthClient.swift
//  OnTheMap
//
//  Created by ABDULRAHMAN ALRAHMA on 12/4/18.
//  Copyright © 2018 ABDULRAHMAN ALRAHMA. All rights reserved.
//

import Foundation
class AuthClient {
    
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"

        case Session
        case User(String)

        var stringValue: String {
            switch self {
            case .Session:
                return Endpoints.base + "/session"
            case .User(let userId):
                return Endpoints.base + "/users/" + (userId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    static func taskForGET<ResponseType: Codable>(url: URL, responseType: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            print(String(data: newData, encoding: .utf8)!)
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: newData) as Error
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
    
    static func taskForPOST<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print(request.debugDescription)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: newData) as Error
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
    
    static func loginRequest(_ username: String, _ password: String, completionHandler: @escaping (SessionResponse?, Error?) -> Void) {
        let body = SessionRequest(udacity: LoginInfo(username: username, password: password))
        taskForPOST(url: Endpoints.Session.url, responseType: SessionResponse.self, body: body) { (response, error) in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    static func getUserInfo(withKey key: String, completionHandler: @escaping (User?, Error?) -> Void) {
        taskForGET(url: Endpoints.User(key).url, responseType: User.self) { (user, error) in
            guard let user = user else {
                completionHandler(nil, error)
                return
            }
            completionHandler(user, nil)
        }
    }
    
    static func deleteSession(completionHandler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: Endpoints.Session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                completionHandler(false)
            }
            completionHandler(true)
        }
        task.resume()
    }
}
