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












let defaultSignedInParameters: [String: AnyObject] = [
    "sid": UserSession.id!
]

let defaultSignedInHeaders: [String: String] = [
    "Authorization": "Token token=\(UserSession.token!)"
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
            
            dispatch_async(dispatch_get_main_queue()) {
                successful = true
            }
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



func updateUserPosition(coordinates: CLLocationCoordinate2D, afterUpdate: (Bool) -> Void) {
    var successful = false
    
    let URL = "\(baseURLString)/users/\(UserSession.User.id!)/sessions/\(UserSession.id!)/positions"
    
    var parameters = defaultSignedInParameters
    
    parameters["position"] = [
        "latitude": coordinates.latitude,
        "longitude": coordinates.longitude
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










