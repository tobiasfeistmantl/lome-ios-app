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
            return "https://lome.herokuapp.com/v1"      // Staging: "https://lome-staging.herokuapp.com/v1"
        }
    }
    
    static var defaultSignedInHeaders: [String: String] {
        return [ "Authorization": "Token token=\(UserSession.id!):\(UserSession.token!)" ]
    }
    
    static func request(method: Alamofire.Method, _ path: String, parameters: [String: AnyObject]? = nil, encoding: ParameterEncoding = .URL, headers: [String: String]? = nil) -> Alamofire.Request {
        let URLString: URLStringConvertible = "\(API.baseURLString)\(path)"
        
        let request = Alamofire.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        
        request.responseJSON { serverResponse in
            let result = serverResponse.result
            if let value = result.value {
                let data = JSON(value)
                
                if data["error"]["type"].string == "UNAUTHENTICATED" {
                    UserSession.delete()
                    
                    let welcomeViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()!
                    UIViewController.topMost.presentViewController(welcomeViewController, animated: true, completion: nil)
                    
                    return
                }
            }
        }
        
        return request
    }
    
    class Posts {
        static func getPostsNearby(page page: Int = 1, afterResponse: ([Post], Bool) -> Void) {
            var posts: [Post] = []
            var successful = false
            
            let parameters: [String: AnyObject] = [
                "page": page
            ]
            
            API.request(.GET, "/posts/nearby", parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { serverResponse in
                let result = serverResponse.result
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
            
            API.request(.GET, "/users", parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { serverResponse in
                let result = serverResponse.result
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
            
            API.request(.GET, "/users/\(id)", headers: defaultSignedInHeaders).validate().responseJSON { serverResponse in
                let result = serverResponse.result
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
            
            API.request(.PATCH, "/users/\(UserSession.currentUser!.id)", parameters: parameters, headers: defaultSignedInHeaders).responseJSON { serverResponse in
                let response = serverResponse.response
                let result = serverResponse.result
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
            
            let URL = API.baseURLString + "/users/sessions"
            
            Alamofire.request(.POST, URL, headers: headers).validate().responseJSON { serverResponse in
                let result = serverResponse.result
                switch result {
                case .Success(let value):
                    let jsonData = JSON(value)
                    
                    UserSession.id = jsonData["id"].int
                    UserSession.token = jsonData["token"].string
                    
                    let user = User(data: jsonData["user"])
                    UserSession.currentUser = user
                    
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
            
            let URL = baseURLString + "/users"
            
            Alamofire.request(.POST, URL, parameters: parameters).responseJSON { serverResponse in
                let response = serverResponse.response
                let result = serverResponse.result
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
            
            API.request(.DELETE, "/users/\(UserSession.currentUser!.id)/sessions/\(UserSession.id!)", headers: defaultSignedInHeaders).responseJSON { serverResponse in
                let response = serverResponse.response
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
            static func get(user: User, page: Int = 1, afterResponse: ([Post], Bool) -> Void) {
                var posts: [Post] = []
                var successful = false
                
                let parameters = [
                    "page": page
                ]
                
                API.request(.GET, "/users/\(user.id)/posts", parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { serverResponse in
                    let result = serverResponse.result
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
            
            static func reportAbuse(post: Post, afterResponse: (Bool) -> Void) {
                var successful = false
                
                API.request(.POST, "/users/\(post.author.id)/posts/\(post.id)/abuse_report", headers: defaultSignedInHeaders).responseJSON { serverResponse in
                    if serverResponse.response?.statusCode == 201 {
                        successful = true
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        afterResponse(successful)
                    }
                }
            }
            
            static func uploadImage(image: UIImage, afterResponse: (Post?, Bool) -> Void) {
                var post: Post?
                var successful = false
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    let imagePath = image.storeImage("tmpPostImage")
                    let imageURL = NSURL.fileURLWithPath(imagePath!)
                    
                    let URL = API.baseURLString + "/users/\(UserSession.currentUser!.id)/posts/image"
                    
                    Alamofire.upload(.POST, URL, headers: API.defaultSignedInHeaders, multipartFormData: { multipartFormData in
                        multipartFormData.appendBodyPart(fileURL: imageURL, name: "post[image]")
                        }) { encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.validate().responseJSON { serverResponse in
                                    let result = serverResponse.result
                                    switch result {
                                    case .Success(let value):
                                        post = Post(data: JSON(value)["post"])
                                        successful = true
                                    case .Failure:
                                        break
                                    }
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        afterResponse(post, successful)
                                    }
                                }
                            case .Failure:
                                dispatch_async(dispatch_get_main_queue()) {
                                    afterResponse(post, successful)
                                }
                            }
                            
                            UIImage.removeImage("tmpPostImage")
                    }
                }
            }
            
            static func delete(post: Post, afterResponse: (Bool) -> Void) {
                var successful = false
                
                API.request(.DELETE, "/users/\(post.author.id)/posts/\(post.id)", headers: defaultSignedInHeaders).responseJSON { serverResponse in
                    if serverResponse.response?.statusCode == 204 {
                        successful = true
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        afterResponse(successful)
                    }
                }
            }
            
            class Likes {
                static func getUsers(post: Post, page: Int = 1, afterResponse: ([User], Bool) -> Void) {
                    var users: [User] = []
                    var successful = false
                    
                    let parameters = [
                        "page": page
                    ]
                    
                    API.request(.GET, "/users/\(post.author.id)/post/\(post.id)/likes)", parameters: parameters, headers: API.defaultSignedInHeaders).validate().responseJSON { serverResponse in
                        let result = serverResponse.result
                        switch result {
                        case .Success(let value):
                            successful = true
                            
                            for (_, data) in JSON(value)["likes"] {
                                users.append(User(data: data["user"]))
                            }
                        case .Failure:
                            break
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            afterResponse(users, successful)
                        }
                    }
                }
            }
        }
        
        class Relationships {
            static func get(partner_id: Int, afterResponse: (Bool, Bool, Bool) -> Void) {
                var following = false
                var followed = false
                var successful = false
                
                let parameters = [
                    "partner_id": partner_id
                ]
                
                API.request(.GET, "/users/\(UserSession.currentUser!.id)/relationships", parameters: parameters, headers: API.defaultSignedInHeaders).validate().responseJSON { serverResponse in
                    let result = serverResponse.result
                    switch result {
                    case .Success(let value):
                        successful = true
                        
                        let JSONValue = JSON(value)
                        
                        following = JSONValue["active_relationship"].bool!
                        followed = JSONValue["passive_relationship"].bool!
                    case .Failure:
                        print("Error: Unable to get relationship")
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        afterResponse(following, followed, successful)
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
                
                API.request(.POST, "/users/\(UserSession.currentUser!.id)/sessions/\(UserSession.id!)/positions", parameters: parameters, headers: API.defaultSignedInHeaders).responseJSON { serverResponse in
                    let response = serverResponse.response
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














