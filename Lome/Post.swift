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

class Post {
    var id: Int
    var message: String?
    var location: CLLocation
    var author: User
    var createdAt: NSDate
    var likesCount: Int
    var liked: Bool
    var imageURLs: [PostImageVersion: String] = [:]
    
    var likesCountText: String {
        let text: String
        
        if likesCount == 1 {
            text = "\(likesCount) Like"
        } else {
            text = "\(likesCount) Likes"
        }
        
        return text
    }
    
    var distance: Double?
    
    func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        let distance = location.distanceFromLocation(self.location)
        self.distance = distance
        
        return distance
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
        
        annotation.coordinate = location.coordinate
        
        return annotation
    }
    
    init(id: Int, message: String?, location: CLLocation, author: User, createdAt: NSDate, likesCount: Int, liked: Bool, imageURLs: [PostImageVersion: String]) {
        self.id = id
        self.message = message
        self.location = location
        self.author = author
        self.likesCount = likesCount
        self.createdAt = createdAt
        self.liked = liked
        self.imageURLs = imageURLs
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.message = data["message"].string
        self.likesCount = data["likes_count"].int!
        self.location = CLLocation(latitude: data["latitude"].double!, longitude: data["longitude"].double!)
        self.author = User(data: data["author"])
        self.createdAt = railsDateFormatter.dateFromString(data["created_at"].string!)!
        self.liked = data["liked"].bool!
        
        for (key, jsonURL) in data["image"] {
            self.imageURLs[PostImageVersion(rawValue: key)!] = jsonURL.string
        }
    }
    
    var distanceText: String? {
        if let distance = distance {
            var text: String
            
            switch distance {
            case 0...5:
                text = "Placed exactly here"
            case 5...1000:
                text = "Placed in \(Int(distance))m"
            default:
                text = "Placed in \(Int(distance / 1000))km"
            }
            
            return text
        }
        
        return nil
    }
    
    func like(like: Bool, button: UIButton? = nil, barButton: UIBarButtonItem? = nil, likeCountLabel: UILabel? = nil) {
        let URL = baseURLString + "/users/\(author.id)/posts/\(id)/like"
        
        liked = like
        
        let method: Alamofire.Method
        
        if let button = button {
            button.setImage(likeButtonImage, forState: .Normal)
        }
        
        if let barButton = barButton {
            barButton.image = likeButtonImage
        }
        
        if like {
            method = .POST
            likesCount += 1
        } else {
            method = .DELETE
            likesCount -= 1
        }
        
        likeCountLabel?.text = likesCountText
        
        Alamofire.request(method, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders)
    }
    
    var likeButtonImage: UIImage {
        if liked {
            return UIImage(named: "Liked Heart")!
        }
        
        return UIImage(named: "Like Heart")!
    }
    
    func image(version postImageVersion: PostImageVersion = .Original, afterResponse: (UIImage?, Bool) -> Void) {
        var image: UIImage?
        var successful = false
        
        if let imageURL = imageURLs[postImageVersion] {
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

enum PostImageVersion: String {
    case Original = "original"
    case Thumbnail = "thumbnail"
}














