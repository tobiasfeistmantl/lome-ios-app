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
            postImageButton.isHidden = postImage == nil
        }
    }
    
    var post: Post! {
        didSet {
            if let imageURL = post.author.profileImageURLs[.Thumbnail] {
                if let URL = URL(string: imageURL) {
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
                usernameLabel.isHidden = true
            }
            
            if let attributedMessage = post.attributedMessage {
                messageLabel.attributedText = attributedMessage
                messageLabel.isHidden = false
                constraintBetweenMessageLabelAndPostImageView.constant = 18
            } else {
                messageLabel.isHidden = true
                messageLabel.attributedText = nil
                constraintBetweenMessageLabelAndPostImageView.constant = 0
            }
            
            setNeedsUpdateConstraints()
            
            if let imageURL = post.imageURLs[.Original] {
                let URL = Foundation.URL(string: imageURL)!
                
                postImageActivityIndicator.startAnimating()
                postImageView.af_setImageWithURL(URL, placeholderImage: nil, filter: nil, imageTransition: .None) { serverResponse in
                    let result = serverResponse.result
                    self.postImageActivityIndicator.stopAnimating()
                    
                    if let image = result.value {
                        self.postImage = image
                    }
                }
            } else {
                constraintBetweenMessageLabelAndPostImageView.constant = 0
            }
            
            post.likeItems[.button] = likeButton
            post.likeItems[.countLabel] = likeCountButton.titleLabel
            
            timestampLabel.text = String(format: NSLocalizedString("Posted %@", comment: "Posted {n-time ago}"), (post.createdAt as Date).timeAgoSinceNow())
            distanceLabel.text = post.distanceText
            likeCountButton.setTitle(post.likesCountText, for: UIControlState())
            likeButton.setImage(post.likeButtonImage, for: UIControlState())
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
    
    @IBAction func postImageButtonDidTouch(_ sender: TFImageButton) {
        if let postImage = postImage {
            sender.showImage(postImage)
        }
    }
    
    @IBAction func moreButtonDidTouch(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report Post", style: .destructive) { _ in
            self.reportPost()
        }
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deletePost()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        
        if UserSession.currentUser!.isAllowedToChangePost(post) {
            alert.addAction(deleteAction)
        }
        
        UIViewController.topMost.present(alert, animated: true, completion: nil)
    }
    
    func reportPost() {
        let alert = UIAlertController(title: "Report Abuse", message: "Do you really want to report this post?", preferredStyle: .alert)
        let reportAction = UIAlertAction(title: "Yes report!", style: UIAlertActionStyle.destructive) { _ in
            API.Users.Posts.reportAbuse(self.post) { successful in
                if successful {
                    UIViewController.topMost.simpleAlert(title: "Post reported!", message: "Thank you for your help!")
                } else {
                    UIViewController.topMost.simpleAlert(title: "Unable to report!", message: "There was a problem while report the post!")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        UIViewController.topMost.present(alert, animated: true, completion: nil)
    }
    
    func deletePost() {
        let alert = UIAlertController(title: "Delete Post", message: "Do you really want to delete this post?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) { _ in
            API.Users.Posts.delete(self.post) { successful in
                if successful {
                    UIViewController.topMost.simpleAlert(title: "Post deleted!", message: "Post was successfully deleted")
                } else {
                    UIViewController.topMost.simpleAlert(title: "Unable to delete post!", message: nil)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        UIViewController.topMost.present(alert, animated: true, completion: nil)
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
        usernameLabel.isHidden = false
        postImageAspectConstraint = nil
        postImageActivityIndicator.stopAnimating()
        postImageButton.isHidden = true
    }
}








extension PostTableViewCell {
    func setupUserProfileButton(_ indexPath: IndexPath, viewController: UIViewController) {
        userProfileButton.indexPath = indexPath
        userProfileButton.addTarget(viewController, action: Selector("userProfileButtonDidTouch:"), for: .touchUpInside)
        userProfileButton.isHidden = false
    }
    
    
    @IBAction func likeButtonDidTouch(_ sender: UIButton) {
        post.like = !post.like
    }
}
