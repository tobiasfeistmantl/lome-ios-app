//
//  Post.swift
//  Lome
//
//  Created by Tobias Feistmantl on 17/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SwiftyJSON
import Alamofire

struct Post {
    var message: String?
    var coordinates: CLLocationCoordinate2D
    var author: User
    var image: UIImage?
    var imageVersion: PostImageVersion?
    var likesCount: Int
    
    init(message: String?, coordinates: CLLocationCoordinate2D, author: User, image: UIImage?, likesCount: Int) {
        self.message = message
        self.coordinates = coordinates
        self.author = author
        self.image = image
        self.likesCount = likesCount
    }
    
    init(data: JSON, imageVersion: PostImageVersion) {
        self.message = data["message"].string
        self.likesCount = data["likes_count"].int!
        self.coordinates = CLLocationCoordinate2D(latitude: data["latitude"].double!, longitude: data["longitude"].double!)
        self.imageVersion = imageVersion
        self.author = User(data: data["author"], profileImageVersion: .Thumbnail)
        
        if let imageURL = data["image"][imageVersion.rawValue].string {
            Alamofire.request(.GET, imageURL).responseJSON { (_, _, result) in
                if let value = result.value {
                    self.image = UIImage(data: value as! NSData)
                }
            }
        }
    }
}

enum PostImageVersion: String {
    case LowResolution = "low_resolution"
    case StandardResolution = "standard_resolution"
    case HighResolution = "high_resolution"
    case Thumbnail = "thumbnail"
}