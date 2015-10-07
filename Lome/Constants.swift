//
//  Constants.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
let usernameRegex = "(?![-_.])(?!.*[-_.]{2})[a-zA-Z0-9._-]+(?<![-_.])"

let likeHeartImage = UIImage(named: "Like Heart")
let likedHeartImage = UIImage(named: "Liked Heart")

let profileFallbackImages = ["Pink", "Magenta", "Cyan", "Green", "Yellow", "Orange", "Dark Red"]
var count = 0

var profileFallbackImage: UIImage {
    if count >= profileFallbackImages.count {
        count = 0
    }
    
    return UIImage(named: "\(profileFallbackImages[count++]) Fallback")!
}