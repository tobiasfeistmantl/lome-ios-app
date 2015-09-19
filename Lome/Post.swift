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
import MapKit

struct Post {
    var id: Int
    var message: String?
    var coordinates: CLLocationCoordinate2D
    var author: User
    var createdAt: NSDate
    var likesCount: Int
    var liked: Bool
    
    var likesCountText: String {
        let text: String
        
        if likesCount == 1 {
            text = "\(likesCount) Like"
        } else {
            text = "\(likesCount) Likes"
        }
        
        return text
    }
    
    var distanceInKm: Float?
    var distance: Int? {
        if let distanceInKm = distanceInKm {
            let distanceInMeters = Int(distanceInKm * 1000)
            
            return distanceInMeters
        }
        
        return nil
    }
    
    var attributedMessage: NSAttributedString? {
        if let message = message {
            let attributedMessage = NSMutableAttributedString(string: message)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            
            attributedMessage.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedMessage.length))
            
            return attributedMessage
        }
        
        return nil
    }
    
    var mapAnnotation: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinates
        
        return annotation
    }
    
    init(id: Int, message: String?, coordinates: CLLocationCoordinate2D, author: User, createdAt: NSDate, likesCount: Int, liked: Bool) {
        self.id = id
        self.message = message
        self.coordinates = coordinates
        self.author = author
        self.likesCount = likesCount
        self.createdAt = createdAt
        self.liked = liked
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.message = data["message"].string
        self.likesCount = data["likes_count"].int!
        self.coordinates = CLLocationCoordinate2D(latitude: data["latitude"].double!, longitude: data["longitude"].double!)
        self.author = User(data: data["author"])
        self.createdAt = railsDateFormatter.dateFromString(data["created_at"].string!)!
        self.liked = data["liked"].bool!
        
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