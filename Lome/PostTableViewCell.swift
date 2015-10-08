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
                postImageView.af_setImageWithURL(URL, placeholderImage: nil, filter: nil, imageTransition: .None) { _, _, result in
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
            likeCountButton.titleLabel?.text = post.likesCountText
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
    
    override func updateConstraints() {
        if let aspectRatio = post.imageAspectRatio {
            postImageAspectConstraint = postImageView.aspectRatioConstraintForMultiplier(aspectRatio)
        }
        
        super.updateConstraints()
    }
    
    @IBAction func likeCountButtonDidTouch(sender: UIButton) {
        let viewController = UIApplication.sharedApplication().keyWindow?.rootViewController!
        
        let likesViewController = LikesViewController()
        likesViewController.post = post
        
        viewController?.presentViewController(likesViewController, animated: true, completion: nil)
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