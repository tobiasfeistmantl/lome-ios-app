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
    
    let parameters: [String: AnyObject] = [
        "sid": UserSession.id!
    ]
    
    let headers: [String: String] = [
        "Authorization": "Token token=\(UserSession.token!)"
    ]
    
    Alamofire.request(.DELETE, URL, parameters: parameters, headers: headers).responseJSON { _, response, _ in
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