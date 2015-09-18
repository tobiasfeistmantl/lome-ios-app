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
import AlamofireImage

struct Post {
    var message: String?
    var coordinates: CLLocationCoordinate2D
    var author: User
    var createdAt: NSDate
    var likesCount: Int
    
    var distanceInKm: Float?
    var distance: Int? {
        if let distanceInKm = distanceInKm {
            let distanceInMeters = Int(distanceInKm * 1000)
            
            return distanceInMeters
        }
        
        return nil
    }
    
    init(message: String?, coordinates: CLLocationCoordinate2D, author: User, createdAt: NSDate, likesCount: Int) {
        self.message = message
        self.coordinates = coordinates
        self.author = author
        self.likesCount = likesCount
        self.createdAt = createdAt
    }
    
    init(data: JSON) {
        self.message = data["message"].string
        self.likesCount = data["likes_count"].int!
        self.coordinates = CLLocationCoordinate2D(latitude: data["latitude"].double!, longitude: data["longitude"].double!)
        self.author = User(data: data["author"])
        self.createdAt = railsDateFormatter.dateFromString(data["created_at"].string!)!
        
        self.distanceInKm = data["distance_in_km"].float
    }
    
    var distanceText: String? {
        if let distance = distance {
            var text: String
            
            switch distance {
            case 0...5:
                text = "Placed exactly here"
            default:
                text = "Placed in \(distance)m"
            }
            
            return text
        }
        
        return nil
    }
}