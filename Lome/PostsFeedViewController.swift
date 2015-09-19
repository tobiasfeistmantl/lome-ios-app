//
//  PostsViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON
import DateTools

class PostsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var newPostButton: DesignableButton!
    
    let locationManager = CLLocationManager()
    
    var posts: [Post] = []
    
    // TODO Example Image only
    let exampleImage = UIImage(named: "Achenlake Example Image")!.af_imageWithAppliedCoreImageFilter("CIPhotoEffectInstant")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem(navigationItem)
        setupLocationManager(locationManager)
        setupTableView(postsTableView)
    }
    
    
    // Location Manager Delegates
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        updateUserPosition(locations[0].coordinate) { successful in
            if successful {
                getPostsNearby { posts, successful in
                    if successful {
                        self.posts = posts
                        self.postsTableView.reloadData()
                    } else {
                        self.simpleAlert(title: "Unable to get posts", message: "Please try again later")
                    }
                }
            } else {
                self.simpleAlert(title: "Unable to update your location", message: "Please try again later")
            }
        }
    }
    
    
    // Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return postTableViewCellAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
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
    }
}







extension PostsFeedViewController {
    func postTableViewCellAtIndexPath(indexPath: NSIndexPath) -> PostTableViewCell {
        let cell = postsTableView.dequeueReusableCellWithIdentifier("postCell") as! PostTableViewCell
        let post = posts[indexPath.row]
        
        cell.post = post
        
        let URL = NSURL(string: "http://localhost:3000/uploads/development/user/profile_image/2/thumb_adb078ac-e039-4fb3-8ac0-d86bedc9a20e.png")
            
        cell.userProfileImageView.af_setImageWithURL(URL!)
        
        if let name = post.author.fullName {
            cell.usersNameLabel.text = name
            cell.usernameLabel.text = post.author.username
        } else {
            cell.usersNameLabel.text = post.author.username
            cell.usernameLabel.hidden = true
        }
        
        if let message = post.message {
            cell.contentLabel.text = message
        } else {
            cell.contentLabel.hidden = true
        }
        
        cell.timestampLabel.text = "Posted \(post.createdAt.timeAgoSinceNow())"
        cell.distanceLabel.text = post.distanceText
        cell.likesLabel.text = "\(post.likesCount) Likes"
        
        Alamofire.request(.GET, "http://localhost:3000/uploads/development/post/image/1/adfac507-952b-4bb5-ac67-3ec5a18c27cc.png").responseImage { _, _, result in
            if let value = result.value {
                cell.postImageView.image = value
            }
        }
        
        return cell
    }
    
    func setupLocationManager(locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func setupTableView(tableView: UITableView) {
        postsTableView.estimatedRowHeight = 301
        postsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupNavigationItem(navigationItem: UINavigationItem) {
        navigationItem.setTitleImage(with: UIImage(named: "Lome Red")!, rect: CGRectMake(0, 0, 91, 32))
    }
}














