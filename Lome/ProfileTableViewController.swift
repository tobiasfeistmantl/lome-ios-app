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
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
    
    // Configure the cell...
    
    return cell
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
