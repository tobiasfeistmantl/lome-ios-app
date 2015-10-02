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
    @IBOutlet weak var userProfileButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var postPositionMapView: MKMapView!
    @IBOutlet weak var likePostButton: UIBarButtonItem!
    @IBOutlet weak var postImageButton: TFImageButton!
    
    @IBOutlet weak var constraintBetweenMessageLabelAndPostImageView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        likesLabel.text = post.likesCountText
        timestampLabel.text = NSString(format: NSLocalizedString("Posted %@", comment: "Posted {n-time ago}"), post.createdAt.timeAgoSinceNow()) as String
        postPositionMapView.addAnnotation(post.mapAnnotation)
        postPositionMapView.zoomToPosition(post.location.coordinate)
        
        post.author.profileImage(version: .Thumbnail) { image, _ in
            self.userProfileImageView.image = image
        }
        
        if let aspectRatio = post.imageAspectRatio {
            postImageView.addConstraint(postImageView.aspectRatioConstraintForMultiplier(aspectRatio))
        }
        
        if let imageURL = post.imageURLs[.Original] {
            let URL = NSURL(string: imageURL)!
            
            postImageButton.hidden = false
            postImageView.af_setImageWithURL(URL)
        }
        
        if let fullName = post.author.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = post.author.username
        } else {
            usersNameLabel.text = post.author.username
            usernameLabel.hidden = true
        }
        
        if let attributedMessage = post.attributedMessage {
            contentLabel.attributedText = attributedMessage
            contentLabel.hidden = false
        } else {
            contentLabel.hidden = true
            contentLabel.attributedText = nil
            constraintBetweenMessageLabelAndPostImageView.constant = 0
        }
        
        post.likeItems[.BarButton] = likePostButton
        post.likeItems[.CountLabel] = likesLabel
        
        if let distanceText = post.distanceText {
            distanceLabel.text = distanceText
        } else {
            distanceLabel.hidden = true
        }
        
        likePostButton.image = post.likeButtonImage
    }
    
    @IBAction func postImageButtonDidTouch(sender: TFImageButton) {
        if let postImage = postImageView.image {
            postImageButton.showImage(postImage)
        }
    }
    
    @IBAction func likePostButtonDidTouch(sender: UIBarButtonItem) {
        post.like = !post.like
    }
    
    @IBAction func userProfileButtonDidTouch(sender: UIButton) {
        performSegueWithIdentifier("showUserProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUserProfile" {
            let destinationViewController = segue.destinationViewController as! ProfileTableViewController
            
            destinationViewController.user = post.author
        }
    }
    
}
