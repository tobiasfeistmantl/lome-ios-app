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
    
    var user: User! {
        didSet {
            userId = user.id
        }
    }
    
    
    var posts: [Post] = []
    
    @IBOutlet weak var profileInformationView: UIView!
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            setUser()
        } else {
            userId = user.id
            self.setupUserViews()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setUser", name: "userUpdated", object: nil)
        
        setupTableView()
    }
    
    func setUser() {
        getUser(userId) { user, successful in
            if successful {
                self.user = user
                self.setupUserViews()
            } else {
                self.simpleAlert(title: "Unable to get User Information", message: "Please try again later")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func followButtonDidTouch(sender: DesignableButton) {
        if !user.following {
            user.follow(true)
            sender.setTitle("Unfollow", forState: .Normal)
            sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            sender.backgroundColor = UIColor(hex: "4A90E2")
        } else {
            user.follow(false)
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
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        performSegueWithIdentifier("showPost", sender: cell)
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPost" {
            let cell = (sender as! PostTableViewCell)
            let post = cell.post
            let destinationViewController = segue.destinationViewController as! PostViewController
            
            destinationViewController.post = post
        }
        
        if segue.identifier == "showSettings" {
            let destinationViewController = segue.destinationViewController as! ProfileDashboardTableViewController
            
            destinationViewController.user = user
        }
    }
    
    
    
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "postCell")
        tableView.estimatedRowHeight = 301
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupUserViews() {
        if let imageURL = user.profileImageURLs[.Original] {
            let URL = NSURL(string: imageURL)
            
            profileImageView.af_setImageWithURL(URL!)
        }
        
        
        if user.following {
            followButton.backgroundColor = UIColor(hex: "4A90E2")
            followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            followButton.setTitle("Unfollow", forState: .Normal)
        }
        
        
        if let fullName = user.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = user.username
        } else {
            usersNameLabel.text = user.username
            usernameLabel.hidden = true
        }
        
        followerLabel.text = "\(user.followerCount) Follower"
        
        if UserSession.User.id == user.id {
            if followButton.hidden == false {
                followButton.hidden = true
                profileInformationView.frame = CGRectMake(profileInformationView.frame.origin.x, profileInformationView.frame.origin.y, profileInformationView.frame.size.width, (profileInformationView.frame.size.height - followButton.frame.size.height - 10))
            }
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        getUsersPosts(user) { posts, successful in
            if successful {
                self.posts = posts
                
                self.tableView.reloadData()
            } else {
                self.simpleAlert(title: "Unable to load posts", message: "Please try again later")
            }
        }
    }
}
