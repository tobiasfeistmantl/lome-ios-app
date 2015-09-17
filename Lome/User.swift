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

struct User {
    var id: Int
    var firstname: String?
    var lastname: String?
    var username: String
    var email: String?
    var profileImage: UIImage?
    var profileImageVersion: ProfileImageVersion?
    var followerCount: Int
    
    var fullName: String? {
        if firstname != nil && lastname != nil {
            return "\(firstname!) \(lastname)"
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
    
    init(data: JSON, profileImageVersion: ProfileImageVersion) {
        self.id = data["id"].int!
        self.firstname = data["firstname"].string
        self.lastname = data["lastname"].string
        self.username = data["username"].string!
        self.email = data["email"].string
        self.followerCount = data["followerCount"].int!
        self.profileImageVersion = profileImageVersion
        
        if let imageURL = data["profile_image"][profileImageVersion.rawValue].string {
            Alamofire.request(.GET, imageURL).responseJSON { (_, _, result) in
                if let value = result.value {
                    self.profileImage = UIImage(data: value as! NSData)
                }
            }
        }
    }
}

enum ProfileImageVersion: String {
    case StandardResolution = "standard_resolution"
    case Thumbnail = "thumbnail"
}