//
//  ProfileTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring
import Alamofire
import SwiftyJSON

class ProfileTableViewController: UITableViewController {
    var userId: Int!
    
    var user: User?
    var posts: [Post] = []
    
    // To refresh the cell if the user clicked the like button
    var indexPathOfVisitedPost: NSIndexPath?
    
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followButton: DesignableButton!
    @IBOutlet weak var followButtonHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URL = baseURLString + "/users/\(userId)"
        
        if user == nil {
            Alamofire.request(.GET, URL, parameters: defaultSignedInParameters, headers: defaultSignedInHeaders).responseJSON { _, _, result in
                if let value = result.value {
                    self.user = User(data: JSON(value))
                    
                    self.setupUserViews()
                }
            }
        } else {
            self.setupUserViews()
        }
        
        setupTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = indexPathOfVisitedPost {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! PostTableViewCell
            
            cell.refreshCell()
            
            indexPathOfVisitedPost = nil
        }
    }
    
    @IBAction func followButtonDidTouch(sender: DesignableButton) {
        if !user!.following {
            user?.follow(true)
            sender.setTitle("Unfollow", forState: .Normal)
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            sender.backgroundColor = UIColor(hex: "4A90E2")
        } else {
            user?.follow(false)
            sender.setTitle("Follow", forState: .Normal)
            sender.setTitleColor(UIColor(hex: "4A90E2"), forState: .Normal)
            sender.backgroundColor = UIColor.whiteColor()
        }
        
        followerLabel.text = user!.followerCountText
    }
    
    
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostTableViewCell
        let post = posts[indexPath.row]
        
        cell.setupWithPost(post, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        indexPathOfVisitedPost = indexPath
        
        performSegueWithIdentifier("showPost", sender: cell)
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPost" {
            let cell = (sender as! PostTableViewCell)
            let post = cell.post
            let destinationViewController = segue.destinationViewController as! PostViewController
            
            destinationViewController.post = post
        }
    }
    
    
    
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "postCell")
        tableView.estimatedRowHeight = 301
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupUserViews() {
        if let imageURL = user?.profileImageURLs[.StandardResolution] {
            if let imageURL = imageURL {
                let URL = NSURL(string: imageURL)
                
                profileImageView.af_setImageWithURL(URL!)
            }
        }
        
        
        if user!.following {
            followButton.backgroundColor = UIColor(hex: "4A90E2")
            followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            followButton.setTitle("Unfollow", forState: .Normal)
        }
        
        
        if let fullName = user?.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = user!.username
        } else {
            usersNameLabel.text = user!.username
            usernameLabel.hidden = true
        }
        
        followerLabel.text = "\(user!.followerCount) Follower"
        
        if UserSession.User.id == userId {
            followButton.hidden = true
            followButtonHeightConstraint.constant = 0
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        getUsersPosts(user!) { posts, successful in
            if successful {
                self.posts = posts
                
                self.tableView.reloadData()
            } else {
                self.simpleAlert(title: "Unable to load posts", message: "Please try again later")
            }
        }
    }
}
