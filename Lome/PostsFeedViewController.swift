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
    
    // To refresh the cell if the user clicked the like button
    var indexPathOfVisitedPost: NSIndexPath?
    
    // TODO Example Image only
    let exampleImage = UIImage(named: "Achenlake Example Image")!.af_imageWithAppliedCoreImageFilter("CIPhotoEffectInstant")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItem(navigationItem)
        setupLocationManager(locationManager)
        setupTableView(postsTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = indexPathOfVisitedPost {
            let cell = postsTableView.cellForRowAtIndexPath(indexPath) as! PostTableViewCell
            
            cell.likeCountLabel.text = cell.post.likesCountText
            cell.likeButton.setImage(cell.post.likeButtonImage, forState: .Normal)
            
            indexPathOfVisitedPost = nil
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostTableViewCell
        
        cell.setupWithPost(posts[indexPath.row], indexPath: indexPath, viewController: self)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        indexPathOfVisitedPost = indexPath
        
        performSegueWithIdentifier("showPost", sender: cell)
    }
    
    func userProfileButtonDidTouch(sender: TFCellButton) {
        performSegueWithIdentifier("showUserProfileFromCell", sender: sender)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPost" {
            let cell = (sender as! PostTableViewCell)
            let post = cell.post
            let destinationViewController = segue.destinationViewController as! PostViewController
                
            destinationViewController.post = post
        }
        
        if segue.identifier == "showUserProfile" {
            let destinationViewController = segue.destinationViewController as! ProfileTableViewController
            destinationViewController.userId = UserSession.User.id!
        }
        
        if segue.identifier == "showUserProfileFromCell" {
            let button = sender as! TFCellButton
            let post = posts[button.indexPath!.row]
            
            let destinationViewController = segue.destinationViewController as! ProfileTableViewController
            destinationViewController.userId = post.author.id
        }
    }
}







extension PostsFeedViewController {
    
    func setupLocationManager(locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func setupTableView(tableView: UITableView) {
        postsTableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "postCell")
        postsTableView.estimatedRowHeight = 301
        postsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupNavigationItem(navigationItem: UINavigationItem) {
        navigationItem.setTitleImage(with: UIImage(named: "Lome Red")!, rect: CGRectMake(0, 0, 91, 32))
    }
}














