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
    var profileImageAspectRatio: Double?
    var profileImageURLs: [ImageVersion: String] = [:]
    var following: Bool?
    
    var followerCountText: String {
        return "\(followerCount) Follower"
    }
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return [firstname!, lastname!].joinWithSeparator(" ")
        }
        
        return nil
    }
    
    init(id: Int, firstname: String?, lastname: String?, username: String, followerCount: Int, profileImageAspectRatio: Double, profileImageURLs: [ImageVersion: String], following: Bool) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.followerCount = followerCount
        self.profileImageAspectRatio = profileImageAspectRatio
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
        self.profileImageAspectRatio = data["profile_image"]["aspect_ratio"].double
        
        for (key, jsonData) in data["profile_image"]["versions"] {
            self.profileImageURLs[ImageVersion(rawValue: key)!] = jsonData.string
        }
        
        self.following = data["following"].bool
    }
    
    func follow(follow: Bool) {
        following = follow
        
        let parameters = [
            "relationship": [
                "followed_id": id
            ]
        ]
        
        let method: Alamofire.Method
        
        if follow {
            followerCount++
            method = .POST
        } else {
            followerCount--
            method = .DELETE
        }
        
        API.request(method, "/users/\(UserSession.User.id!)/relationships", parameters: parameters, headers: API.defaultSignedInHeaders)
    }
    
    func profileImage(version profileImageVersion: ImageVersion = .Original, afterResponse: (UIImage?, Bool) -> Void) {
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














