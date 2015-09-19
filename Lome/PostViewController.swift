//
//  PostViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import MapKit
import DateTools
import Alamofire
import AlamofireImage

class PostViewController: UIViewController {
    
    var post: Post!
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var postPositionMapView: MKMapView!
    @IBOutlet weak var likePostButton: UIBarButtonItem!
    
    let likeHeartImage = UIImage(named: "Like Heart")
    let likedHeartImage = UIImage(named: "Liked Heart")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        likesLabel.text = post.likesCountText
        timestampLabel.text = "Posted \(post.createdAt.timeAgoSinceNow())"
        postPositionMapView.addAnnotation(post.mapAnnotation)
        postPositionMapView.zoomToPosition(post.coordinates)
        
        
        if let fullName = post.author.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = post.author.username
        } else {
            usersNameLabel.text = post.author.username
            usernameLabel.hidden = true
        }
        
        
        if let attributedMessage = post.attributedMessage {
            contentLabel.attributedText = attributedMessage
        } else {
            contentLabel.hidden = true
        }
        
        
        if let distanceText = post.distanceText {
            distanceLabel.text = distanceText
        } else {
            distanceLabel.hidden = true
        }
        
        if post.liked {
            likePostButton.image = likedHeartImage
        }
    }
    
    @IBAction func likePostButtonDidTouch(sender: UIBarButtonItem) {
        let URL = baseURLString + "/users/\(post.author.id)/posts/\(post.id)/likes"
        
        let method: Alamofire.Method
        
        if !post.liked {
            method = .POST
            post.liked = true
            post.likesCount += 1
            
            likePostButton.image = self.likedHeartImage
        } else {
            method = .DELETE
            post.liked = false
            post.likesCount -= 1
            
            likePostButton.image = self.likeHeartImage
        }
        
        likesLabel.text = post.likesCountText
        
        Alamofire.request(method, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders)
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
