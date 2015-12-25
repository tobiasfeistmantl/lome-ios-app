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
    var role: UserRole = .User
    
    var followerCountText: String {
        return String(format: NSLocalizedString("%@ Follower", comment: "{count} Follower"), "\(followerCount)")
    }
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return [firstname!, lastname!].joinWithSeparator(" ")
        }
        
        return nil
    }
    
    init(id: Int, firstname: String?, lastname: String?, username: String, followerCount: Int, profileImageAspectRatio: Double, profileImageURLs: [ImageVersion: String], following: Bool, role: UserRole = .User) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.followerCount = followerCount
        self.profileImageAspectRatio = profileImageAspectRatio
        self.profileImageURLs = profileImageURLs
        self.following = following
        self.role = role
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.firstname = data["firstname"].string
        self.lastname = data["lastname"].string
        self.username = data["username"].string!
        self.email = data["email"].string
        self.followerCount = data["follower_count"].int!
        self.profileImageAspectRatio = data["profile_image"]["aspect_ratio"].double
        
        if let role = data["role"].int {
            if let role = UserRole(rawValue: role) {
                self.role = role
            }
        }
        
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
        
        API.request(method, "/users/\(UserSession.currentUser!.id)/relationships", parameters: parameters, headers: API.defaultSignedInHeaders)
    }
    
    func profileImage(version profileImageVersion: ImageVersion = .Original, afterResponse: (UIImage, Bool) -> Void) {
        var image: UIImage = profileFallbackImage
        var successful = false
        
        if let imageURL = profileImageURLs[profileImageVersion] {
            Alamofire.request(.GET, imageURL).responseImage { serverResponse in
                let result = serverResponse.result
                if let value = result.value {
                    image = value
                    successful = true
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    afterResponse(image, successful)
                }
            }
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                afterResponse(image, successful)
            }
        }
    }
    
    func isModerator() -> Bool {
        return self.role == UserRole.Moderator
    }
    
    func isAdmin() -> Bool {
        return self.role == UserRole.Admin
    }
    
    func isAllowedToChangePost(post: Post) -> Bool {
        return isModerator() || isAdmin() || self.id == post.author.id
    }
}














