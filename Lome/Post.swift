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
    var imageAspectRatio: Double?
    var imageURLs: [ImageVersion: String] = [:]
    var like: Bool {
        didSet {
            let method: Alamofire.Method
            
            if let button = likeItems[.Button] as? UIButton {
                button.setImage(likeButtonImage, forState: .Normal)
            }
            
            if let barButton = likeItems[.BarButton] as? UIBarButtonItem {
                barButton.image = likeButtonImage
            }
            
            if like {
                method = .POST
                likesCount++
            } else {
                method = .DELETE
                likesCount--
            }
            
            if let likeCountLabel = likeItems[.CountLabel] as? UILabel {
                likeCountLabel.text = likesCountText
            }
            
            API.request(method, "/users/\(author.id)/posts/\(id)/like", headers: API.defaultSignedInHeaders)
        }
    }
    
    var likesCountText: String {
        let text: String
        
        if likesCount == 1 {
            text = "\(likesCount) Like"
        } else {
            text = "\(likesCount) Likes"
        }
        
        return text
    }
    
    func distanceFromLocation(location: CLLocation) -> CLLocationDistance {
        return location.distanceFromLocation(self.location)
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
    
    init(id: Int, message: String?, location: CLLocation, author: User, createdAt: NSDate, likesCount: Int, like: Bool, imageURLs: [ImageVersion: String]) {
        self.id = id
        self.message = message
        self.location = location
        self.author = author
        self.likesCount = likesCount
        self.createdAt = createdAt
        self.like = like
        self.imageURLs = imageURLs
    }
    
    init(data: JSON) {
        self.id = data["id"].int!
        self.message = data["message"].string
        self.likesCount = data["likes_count"].int!
        self.location = CLLocation(latitude: data["latitude"].double!, longitude: data["longitude"].double!)
        self.author = User(data: data["author"])
        self.createdAt = railsDateFormatter.dateFromString(data["created_at"].string!)!
        self.like = data["liked"].bool!
        self.imageAspectRatio = data["image"]["aspect_ratio"].double
        
        for (key, jsonData) in data["image"]["versions"] {
            self.imageURLs[ImageVersion(rawValue: key)!] = jsonData.string
        }
    }
    
    var distanceText: String? {
        if let currentLocation = UserSession.currentLocation {
            let distance = distanceFromLocation(currentLocation)
            
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
    
    var likeItems: [LikeItem: AnyObject] = [:]
    
    var likeButtonImage: UIImage {
        if like {
            return UIImage(named: "Liked Heart")!
        }
        
        return UIImage(named: "Like Heart")!
    }
    
    func image(version postImageVersion: ImageVersion = .Original, afterResponse: (UIImage?, Bool) -> Void) {
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

enum LikeItem {
    case Button
    case BarButton
    case CountLabel
}










