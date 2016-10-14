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
import JTSImageViewController

class ProfileTableViewController: UITableViewController, TFInfiniteScroll {
    var userId: Int!
    
    var user: User! {
        didSet {
            userId = user.id
        }
    }
    
    var nextPage = 1
    var hasReachedTheEnd = false
    var populatingAtTheMoment = false
    
    var posts: [Post] = []
    
    @IBOutlet weak var profileInformationView: UIView!
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followButton: DesignableButton!
    @IBOutlet weak var showProfileImageButton: TFImageButton!
    
    var followsUser: Bool = false {
        didSet {
            if followsUser {
                followButton.setTitle(NSLocalizedString("Unfollow", comment: ""), forState: .Normal)
                followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                followButton.backgroundColor = UIColor(hex: "1A6099")
            } else {
                followButton.setTitle(NSLocalizedString("Follow", comment: ""), forState: .Normal)
                followButton.setTitleColor(UIColor(hex: "1A6099"), forState: .Normal)
                followButton.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cleanView()
        
        if user == nil {
            setUser()
        } else {
            userId = user.id
            
            API.Users.Relationships.get(userId) { following, _, successful in
                self.user.following = following
                self.followsUser = following
            }
            
            self.setupUserViews()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileTableViewController.setUser), name: NSNotification.Name(rawValue: "userUpdated"), object: nil)
        
        setupTableView()
    }
    
    func setUser() {
        API.Users.get(userId) { user, successful in
            if successful {
                self.user = user
                self.setupUserViews()
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to get user information", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if populatingAtTheMoment || hasReachedTheEnd {
            return
        }
        
        if scrollView.almostAtTheEnd {
            populate()
        }
    }
    
    @IBAction func followButtonDidTouch(_ sender: DesignableButton) {
        if user.following != nil && !user.following! {
            user.follow(true)
            followsUser = true
        } else {
            user.follow(false)
            followsUser = false
        }
        
        followerLabel.text = user.followerCountText
    }
    
    func populate(reload: Bool = false) {
        populatingAtTheMoment = true
        
        if reload {
            hasReachedTheEnd = false
            nextPage = 1
        }
        
        if user == nil {
            return
        }
        
        API.Users.Posts.get(user, page: nextPage) { posts, successful in
            if successful {
                if reload {
                    self.posts = posts
                } else {
                    self.posts += posts
                }
                
                if posts.count != 0 {
                    self.nextPage += 1
                } else {
                    self.hasReachedTheEnd = true
                }
                
                self.tableView.reloadData()
                self.populatingAtTheMoment = false
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to get posts", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
    
    @IBAction func showProfileImageButtonDidTouch(_ sender: TFImageButton) {
        sender.showImage(profileImageView.image!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost" {
            let cell = (sender as! PostTableViewCell)
            let post = cell.post
            let destinationViewController = segue.destination as! PostViewController
            
            destinationViewController.post = post
        }
        
        if segue.identifier == "showSettings" {
            let destinationViewController = segue.destination as! ProfileDashboardTableViewController
            
            destinationViewController.user = user
        }
    }
}



extension ProfileTableViewController {
    func setupUserViews() {
        if let imageURL = user.profileImageURLs[.Original] {
            let URL = Foundation.URL(string: imageURL)
            
            profileImageView.af_setImageWithURL(URL!)
        }
        
        
        if user.following != nil && user.following! {
            followButton.backgroundColor = UIColor(hex: "1A6099")
            followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            followButton.setTitle(NSLocalizedString("Unfollow", comment: ""), forState: .Normal)
        }
        
        
        if let fullName = user.fullName {
            usersNameLabel.text = fullName
            usernameLabel.text = user.username
        } else {
            usersNameLabel.text = user.username
            usernameLabel.isHidden = true
        }
        
        followerLabel.text = user.followerCountText
        
        if UserSession.currentUser?.id == user.id {
                followButton.hidden = true
                profileInformationView.frame = CGRect(x: profileInformationView.frame.origin.x, y: profileInformationView.frame.origin.y, width: profileInformationView.frame.size.width, height: (profileInformationView.frame.size.height - followButton.frame.size.height - 10))  
        } else {
            navigationItem.rightBarButtonItem = nil
            followButton.hidden = false
        }
        
        populate(reload: true)
    }
    
    func cleanView() {
        usersNameLabel.text = ""
        usernameLabel.text = ""
        followerLabel.text = ""
    }
}



extension ProfileTableViewController {
    func setupTableView() {
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "postCell")
        tableView.estimatedRowHeight = 301
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        cell.post = posts[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        performSegue(withIdentifier: "showPost", sender: cell)
    }
}
