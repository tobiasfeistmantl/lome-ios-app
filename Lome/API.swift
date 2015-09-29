//
//  API.swift
//  Lome
//
//  Created by Tobias Feistmantl on 29/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class API {
    
    static var baseURLString: String {
        if UIDevice.currentDevice().name == "iPhone Simulator" {
            return "http://localhost:3000/v1"
        } else {
            return "https://lome-staging.herokuapp.com/v1"
        }
        
        // TODO Change for production
    }
    
    static let defaultSignedInHeaders: [String: String] = [
        "Authorization": "Token token=\(UserSession.id!):\(UserSession.token!)"
    ]
    
    static func request(method: Alamofire.Method, _ path: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, headers: [String: String]? = nil) -> Alamofire.Request {
        let URLString: URLStringConvertible = "\(API.baseURLString)\(path)"
        
        let request = Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        
        request.responseJSON { request, response, result in
            if let value = result.value {
                let data = JSON(value)
                    
                if data["error"]["type"].string == "UNAUTHENTICATED" {
                    UserSession.delete()
                }
            }
        }
        
        return request
    }
    
    class Posts {
        static func getPostsNearby(afterResponse: ([Post], Bool) -> Void) {
            var posts: [Post] = []
            var successful = false
            
            API.request(.GET, "/posts/nearby", headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
                switch result {
                case .Success(let value):
                    for (_, data) in JSON(value) {
                        posts.append(Post(data: data))
                    }
                    
                    successful = true
                case .Failure:
                    break
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterResponse(posts, successful)
                }
            }
        }
    }
    
    class Users {
        static func searchByUsername(q: String, page: Int = 1, afterResponse: ([User], Bool) -> Void) {
            var users: [User] = []
            var successful = false
            
            let parameters: [String: AnyObject] = [
                "q": q,
                "page": page
            ]
            
            API.request(.GET, "/users", parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
                switch result {
                case .Success(let value):
                    for (_, json) in JSON(value) {
                        users.append(User(data: json))
                    }
                    
                    successful = true
                case .Failure:
                    break
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterResponse(users, successful)
                }
            }
        }
        
        static func get(id: Int, afterResponse: (User?, Bool) -> Void) {
            var user: User?
            var successful = false
            
            API.request(.GET, "/users/\(id)", headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
                switch result {
                case .Success(let value):
                    successful = true
                    
                    user = User(data: JSON(value))
                case .Failure:
                    break
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterResponse(user, successful)
                }
            }
        }
        
        static func update(parameters: [String: AnyObject], afterUpdate: (User?, Bool) -> Void) {
            var user: User?
            var successful = false
            
            API.request(.PATCH, "/users/\(UserSession.User.id!)", parameters: parameters, headers: defaultSignedInHeaders).responseJSON { _, response, result in
                if response?.statusCode == 200 {
                    if let value = result.value {
                        user = User(data: JSON(value))
                    }
                    
                    successful = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterUpdate(user, successful)
                }
            }
        }
        
        static func signIn(username: String, password: String, afterSignIn: (Bool) -> Void) {
            var successful = false
            
            let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
            
            let headers = ["Authorization": "Basic \(base64Credentials)"]
            
            Alamofire.request(.POST, "/users/sessions", headers: headers).validate().responseJSON { _, _, result in
                switch result {
                case .Success(let value):
                    let jsonData = JSON(value)
                    
                    UserSession.id = jsonData["id"].int
                    UserSession.token = jsonData["token"].string
                    UserSession.User.id = jsonData["user"]["id"].int
                    UserSession.User.username = jsonData["user"]["username"].string
                    
                    successful = true
                case .Failure:
                    break
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterSignIn(successful)
                }
            }
        }
        
        static func signUp(userParameters: [String: String], afterSignUp: (Bool, JSON?) -> Void) {
            var successful = false
            var APIError: JSON?
            
            let parameters: [String: AnyObject] = [
                "user": userParameters
            ]
            
            Alamofire.request(.POST, "/users", parameters: parameters).responseJSON { _, response, result in
                if response?.statusCode == 201 {
                    successful = true
                } else {
                    if let value = result.value {
                        APIError = JSON(value)
                    }
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterSignUp(successful, APIError)
                }
            }
            
        }
        
        static func signOut(afterSignOut: ((Bool) -> Void)?) {
            var successful = false
            
            API.request(.DELETE, "/users/\(UserSession.User.id!)/sessions/\(UserSession.id!)", headers: defaultSignedInHeaders).responseJSON { _, response, _ in
                UserSession.delete()
                
                if response?.statusCode == 204 {
                    successful = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    if afterSignOut != nil {
                        afterSignOut!(successful)
                    }
                }
            }
        }
        
        class Posts {
            static func get(user: User, afterResponse: ([Post], Bool) -> Void) {
                var posts: [Post] = []
                var successful = false
                
                API.request(.GET, "/users/\(user.id)/posts", headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
                    switch result {
                    case .Success(let value):
                        for (_, data) in JSON(value) {
                            posts.append(Post(data: data))
                        }
                        
                        successful = true
                    case .Failure:
                        break
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        afterResponse(posts, successful)
                    }
                }
            }
        }
        
        static var currentlyUpdatingLocation = false
        
        class Positions {
            static func update(location: CLLocation, afterUpdate: (Bool) -> Void) {
                if currentlyUpdatingLocation {
                    return
                }
                
                currentlyUpdatingLocation = true
                
                var successful = false
                
                let parameters: [String: AnyObject] = [
                    "position": [
                        "latitude": location.coordinate.latitude,
                        "longitude": location.coordinate.longitude
                    ]
                ]
                
                
                API.request(.POST, "/users/\(UserSession.User.id!)/sessions/\(UserSession.id!)/positions", parameters: parameters, headers: defaultSignedInHeaders).responseJSON { _, response, _ in
                    if response?.statusCode == 204 {
                        successful = true
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        currentlyUpdatingLocation = false
                        afterUpdate(successful)
                    }
                }
            }
        }
    }
}














