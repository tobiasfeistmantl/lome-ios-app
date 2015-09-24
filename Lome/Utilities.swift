//
//  Utilities.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation



var railsDateFormatter: NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    return dateFormatter
}











let defaultSignedInParameters: [String: AnyObject] = [:]

let defaultSignedInHeaders: [String: String] = [
    "Authorization": "Token token=\(UserSession.id!):\(UserSession.token!)"
]


func signInUser(username: String, password: String, afterSignIn: (Bool) -> Void) {
    var successful = false
    
    let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
    let base64Credentials = credentialData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithCarriageReturn)
    
    let headers = ["Authorization": "Basic \(base64Credentials)"]
    
    Alamofire.request(.POST, baseURLString + "/users/sessions", headers: headers).validate().responseJSON { _, _, result in
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

func signUpUser(userParameters: [String: String], afterSignUp: (Bool, JSON?) -> Void) {
    var successful = false
    var APIError: JSON?
    
    let parameters: [String: AnyObject] = [
        "user": userParameters
    ]
    
    Alamofire.request(.POST, baseURLString + "/users", parameters: parameters).responseJSON { _, response, result in
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


func signOutUser(afterSignOut: ((Bool) -> Void)?) {
    var successful = false
    
    let URL = "\(baseURLString)/users/\(UserSession.User.id!)/sessions/\(UserSession.id!)"
    
    Alamofire.request(.DELETE, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders).responseJSON { _, response, _ in
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



func updateUserPosition(location: CLLocation, afterUpdate: (Bool) -> Void) {
    var successful = false
    
    let URL = "\(baseURLString)/users/\(UserSession.User.id!)/sessions/\(UserSession.id!)/positions"
    
    var parameters = defaultSignedInParameters
    
    parameters["position"] = [
        "latitude": location.coordinate.latitude,
        "longitude": location.coordinate.longitude
    ]
    
    Alamofire.request(.POST, URL, parameters: parameters, headers: defaultSignedInHeaders).responseJSON { _, response, _ in
        if response?.statusCode == 204 {
            successful = true
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            afterUpdate(successful)
        }
    }
}


func updateUser(parameters: [String: AnyObject], afterUpdate: (User?, Bool) -> Void) {
    var user: User?
    var successful = false
    
    let URL = baseURLString + "/users/\(UserSession.User.id!)"
    
    Alamofire.request(.PATCH, URL, parameters: parameters, headers: defaultSignedInHeaders).responseJSON { _, response, result in
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


func getPostsNearby(afterResponse: ([Post], Bool) -> Void) {
    var posts: [Post] = []
    var successful = false
    
    Alamofire.request(.GET, baseURLString + "/posts/nearby", parameters: defaultSignedInParameters, headers: defaultSignedInHeaders).validate().responseJSON { _, response, result in
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

func getUsersPosts(user: User, afterResponse: ([Post], Bool) -> Void) {
    var posts: [Post] = []
    var successful = false
    
    let URL = baseURLString + "/users/\(user.id)/posts"
    
    Alamofire.request(.GET, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
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

func getUser(id: Int, afterResponse: (User?, Bool) -> Void) {
    var user: User?
    var successful = false
    
    let URL = baseURLString + "/users/\(id)"
    
    Alamofire.request(.GET, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
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

func searchUserByUsername(q: String, page: Int = 1, afterResponse: ([User], Bool) -> Void) {
    var users: [User] = []
    var successful = false
    
    let URL = baseURLString + "/users"
    
    let parameters: [String: AnyObject] = [
        "q": q,
        "page": page
    ]
    
    Alamofire.request(.GET, URL, parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
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



















