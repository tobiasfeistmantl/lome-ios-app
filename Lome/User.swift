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

struct User {
    var id: Int
    var firstname: String?
    var lastname: String?
    var username: String
    var email: String?
    var followerCount: Int
    var profileImageURLs: [ProfileImageVersion: String?] = [
        .StandardResolution: nil,
        .Thumbnail: nil
    ]
    
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return "\(firstname!) \(lastname!)"
        }
        
        return nil
    }
    
    init(id: Int, firstname: String?, lastname: String?, username: String, followerCount: Int, profileImageURLs: [ProfileImageVersion: String?]) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.followerCount = followerCount
        self.profileImageURLs = profileImageURLs
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
    }
}

enum ProfileImageVersion: String {
    case StandardResolution = "standard_resolution"
    case Thumbnail = "thumbnail"
}