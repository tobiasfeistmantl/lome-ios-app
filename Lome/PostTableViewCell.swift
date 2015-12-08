//
//  PostTableViewCell.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Alamofire
import JTSImageViewController

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileButton: TFCellButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var constraintBetweenMessageLabelAndPostImageView: NSLayoutConstraint!
    @IBOutlet weak var postImageButton: UIButton!
    
    @IBOutlet weak var reportAbuseButton: UIButton!
    
    @IBOutlet weak var postImageActivityIndicator: UIActivityIndicatorView!
    
    var postImage: UIImage? {
        didSet {
            postImageButton.hidden = postImage == nil
        }
    }
    
    var post: Post! {
        didSet {
            if let imageURL = post.author.profileImageURLs[.Thumbnail] {
                if let URL = NSURL(string: imageURL) {
                    userProfileImageView.af_setImageWithURL(URL)
                }
            } else {
                userProfileImageView.image = profileFallbackImage
            }
            
            if let name = post.author.fullName {
                usersNameLabel.text = name
                usernameLabel.text = post.author.username
            } else {
                usersNameLabel.text = post.author.username
                usernameLabel.hidden = true
            }
            
            if let attributedMessage = post.attributedMessage {
                messageLabel.attributedText = attributedMessage
                messageLabel.hidden = false
                constraintBetweenMessageLabelAndPostImageView.constant = 18
            } else {
                messageLabel.hidden = true
                messageLabel.attributedText = nil
                constraintBetweenMessageLabelAndPostImageView.constant = 0
            }
            
            setNeedsUpdateConstraints()
            
            if let imageURL = post.imageURLs[.Original] {
                let URL = NSURL(string: imageURL)!
                
                postImageActivityIndicator.startAnimating()
                postImageView.af_setImageWithURL(URL, placeholderImage: nil, filter: nil, imageTransition: .None) { serverResponse in
                    let request = serverResponse.request
                    let response = serverResponse.response
                    let result = serverResponse.result
                    self.postImageActivityIndicator.stopAnimating()
                    
                    if let image = result.value {
                        self.postImage = image
                    }
                }
            } else {
                constraintBetweenMessageLabelAndPostImageView.constant = 0
            }
            
            post.likeItems[.Button] = likeButton
            post.likeItems[.CountLabel] = likeCountButton.titleLabel
            
            timestampLabel.text = String(format: NSLocalizedString("Posted %@", comment: "Posted {n-time ago}"), post.createdAt.timeAgoSinceNow())
            distanceLabel.text = post.distanceText
            likeCountButton.setTitle(post.likesCountText, forState: .Normal)
            likeButton.setImage(post.likeButtonImage, forState: .Normal)
        }
    }
    
    var postImageAspectConstraint: NSLayoutConstraint? {
        didSet {
            if let oldValue = oldValue {
                postImageView.removeConstraint(oldValue)
            }
            if let postImageAspectConstraint = postImageAspectConstraint {
                postImageView.addConstraint(postImageAspectConstraint)
            }
        }
    }
    
    @IBAction func postImageButtonDidTouch(sender: TFImageButton) {
        if let postImage = postImage {
            sender.showImage(postImage)
        }
    }
    
    @IBAction func reportAbuseButtonDidTouch(sender: UIButton) {
        let alert = UIAlertController(title: "Report Abuse", message: "Do you really want to report this post?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let reportAction = UIAlertAction(title: "Yes report!", style: UIAlertActionStyle.Destructive) { _ in
            API.Users.Posts.reportAbuse(self.post) { successful in
                if successful {
                    UIViewController.topMost.simpleAlert(title: "Post reported!", message: "Thank you for your help!")
                } else {
                    UIViewController.topMost.simpleAlert(title: "Unable to report!", message: "There was a problem while report the post!")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        UIViewController.topMost.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func updateConstraints() {
        if let aspectRatio = post.imageAspectRatio {
            postImageAspectConstraint = postImageView.aspectRatioConstraintForMultiplier(aspectRatio)
        }
        
        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = nil
        usernameLabel.hidden = false
        postImageAspectConstraint = nil
        postImageActivityIndicator.stopAnimating()
        postImageButton.hidden = true
    }
}








extension PostTableViewCell {
    func setupUserProfileButton(indexPath: NSIndexPath, viewController: UIViewController) {
        userProfileButton.indexPath = indexPath
        userProfileButton.addTarget(viewController, action: "userProfileButtonDidTouch:", forControlEvents: .TouchUpInside)
        userProfileButton.hidden = false
    }
    
    
    @IBAction func likeButtonDidTouch(sender: UIButton) {
        post.like = !post.like
    }
}