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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        if let fullName = post.author.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = post.author.username
        } else {
            usersNameLabel.text = post.author.username
            usernameLabel.hidden = true
        }
        
        if let content = post.message {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            
            let attributedContent = NSMutableAttributedString(string: content)
            attributedContent.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedContent.length))
            
            contentLabel.attributedText = attributedContent
        } else {
            contentLabel.hidden = true
        }
        
        if let distanceText = post.distanceText {
            distanceLabel.text = distanceText
        } else {
            distanceLabel.hidden = true
        }
        
        timestampLabel.text = "Posted \(post.createdAt.timeAgoSinceNow())"
        likesLabel.text = "\(post.likesCount) Likes"
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
