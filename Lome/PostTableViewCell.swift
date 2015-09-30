//
//  PostTableViewCell.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Alamofire

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileButton: TFCellButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var constraintBetweenMessageLabelAndPostImageView: NSLayoutConstraint!
    
    var post: Post! {
        didSet {
            if let imageURL = post.author.profileImageURLs[.Thumbnail] {
                let URL = NSURL(string: imageURL)!
                
                userProfileImageView.af_setImageWithURL(URL)
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
                constraintBetweenMessageLabelAndPostImageView.constant = 15
            } else {
                messageLabel.hidden = true
                messageLabel.attributedText = nil
                constraintBetweenMessageLabelAndPostImageView.constant = 0
            }
            
            setNeedsUpdateConstraints()
            
            if let imageURL = post.imageURLs[.Original] {
                let URL = NSURL(string: imageURL)!
                
                postImageView.af_setImageWithURL(URL)
            }
            
            post.likeItems[.Button] = likeButton
            post.likeItems[.CountLabel] = likeCountLabel
            
            timestampLabel.text = "Posted \(post.createdAt.timeAgoSinceNow())"
            distanceLabel.text = post.distanceText
            likeCountLabel.text = post.likesCountText
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
    
    
    override func updateConstraints() {
        if let aspectRatio = post.imageAspectRatio {
            postImageAspectConstraint = postImageView.aspectRatioConstraintForMultiplier(aspectRatio)
        }
        
        super.updateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        userProfileImageView.image = UIImage(named: "Background")
        postImageAspectConstraint = nil
    }
}








extension PostTableViewCell {
    func setupUserProfileButton(indexPath: NSIndexPath, viewController: UIViewController) {
        userProfileButton.indexPath = indexPath
        userProfileButton.addTarget(viewController, action: "userProfileButtonDidTouch:", forControlEvents: .TouchUpInside)
    }
    
    
    @IBAction func likeButtonDidTouch(sender: UIButton) {
        post.like = !post.like
    }
}