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

var baseURLString: String {
    if UIDevice.currentDevice().name == "iPhone Simulator" {
        return "http://localhost:3000/v1"
    } else {
        return "https://lome-staging.herokuapp.com/v1"
    }
    
    //  // TODO Change for production
}

let likeHeartImage = UIImage(named: "Like Heart")
let likedHeartImage = UIImage(named: "Liked Heart")