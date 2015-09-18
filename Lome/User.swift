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
    var profileImage: UIImage?
    var profileImageURLs: [String: AnyObject]?
    var followerCount: Int
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return "\(firstname!) \(lastname!)"
        }
        
        return nil
    }
    
    init(id: Int, firstname: String?, lastname: String?, username: String, profileImage: UIImage?, followerCount: Int) {
        self.id = id
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.profileImage = profileImage
        self.followerCount = followerCount
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.firstname = data["firstname"].string
        self.lastname = data["lastname"].string
        self.username = data["username"].string!
        self.email = data["email"].string
        self.followerCount = data["follower_count"].int!
        self.profileImageURLs = data["profile_image"].dictionaryObject
    }
}

enum ProfileImageVersion: String {
    case StandardResolution = "standard_resolution"
    case Thumbnail = "thumbnail"
}