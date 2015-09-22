//
//  User.swift
//  Lome
//
//  Created by Tobias Feistmantl on 16/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire

class User {
    var id: Int
    var firstname: String?
    var lastname: String?
    var username: String
    var email: String?
    var followerCount: Int
    var profileImageURLs: [ProfileImageVersion: String] = [:]
    var following: Bool
    
    var followerCountText: String {
        return "\(followerCount) Follower"
    }
    
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return "\(firstname!) \(lastname!)"
        }
        
        return nil
    }
    
    init(id: Int, firstname: String?, lastname: String?, username: String, followerCount: Int, profileImageURLs: [ProfileImageVersion: String], following: Bool) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.followerCount = followerCount
        self.profileImageURLs = profileImageURLs
        self.following = following
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.firstname = data["firstname"].string
        self.lastname = data["lastname"].string
        self.username = data["username"].string!
        self.email = data["email"].string
        self.followerCount = data["follower_count"].int!
        
        self.profileImageURLs[.StandardResolution] = data["profile_image"][ProfileImageVersion.StandardResolution.rawValue].string
        self.profileImageURLs[.Thumbnail] = data["profile_image"][ProfileImageVersion.Thumbnail.rawValue].string
        
        self.following = data["following"].bool!
    }
    
    
    func follow(follow: Bool) {
        following = follow
        
        var parameters = defaultSignedInParameters
        
        let URL = baseURLString + "/users/\(UserSession.User.id!)/relationships"
        
        parameters["relationship"] = [
            "followed_id": id
        ]
        
        let method: Alamofire.Method
        
        if follow {
            followerCount += 1
            method = .POST
        } else {
            followerCount -= 1
            method = .DELETE
        }
        
        Alamofire.request(method, URL, parameters: parameters, headers: defaultSignedInHeaders)
    }
    
    func profileImage(version profileImageVersion: ProfileImageVersion = .StandardResolution, afterResponse: (UIImage?, Bool) -> Void) {
        var image: UIImage?
        var successful = false
        
        if let imageURL = profileImageURLs[profileImageVersion] {
            Alamofire.request(.GET, imageURL).responseImage { _, _, result in
                if let value = result.value {
                    image = value
                    successful = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterResponse(image, successful)
                }
            }
        }
    }
}

enum ProfileImageVersion: String {
    case StandardResolution = "standard_resolution"
    case Thumbnail = "thumbnail"
}















