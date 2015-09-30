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
    var location: CLLocation? {
        didSet {
            UserSession.currentLocation = location
        }
    }
    let refreshControl = UIRefreshControl()
    
    var nextPage = 1
    var hasReachedTheEnd = false
    var populatingPosts = false
    
    var posts: [Post] = []
    
    // TODO Example Image only
    let exampleImage = UIImage(named: "Achenlake Example Image")!.af_imageWithAppliedCoreImageFilter("CIPhotoEffectInstant")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: "refreshPosts", forControlEvents: .ValueChanged)
        postsTableView.addSubview(refreshControl)
        
        showLoadingView("Loading posts near your location")
        
        setupNavigationItem(navigationItem)
        setupLocationManager(locationManager)
        setupTableView(postsTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data to recognize if post has been liked
        postsTableView.reloadData()
    }
    
    func refreshPosts() {
        locationManager.startUpdatingLocation()
    }
    
    
    // Location Manager Delegates
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        location = locations.last
        
        API.Users.Positions.update(location!) { successful in
            if successful {
                self.populatePosts(refresh: true, location: self.location)
            } else {
                self.refreshControl.endRefreshing()
                self.simpleAlert(title: "Unable to update your location", message: "Please try again later")
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if location == nil || hasReachedTheEnd || populatingPosts {
            return
        }
        
        if scrollView.almostAtTheEnd {
            populatePosts(location: location)
        }
    }
    
    func populatePosts(refresh refresh: Bool = false, location: CLLocation? = nil) {
        populatingPosts = true
        
        if refresh {
            hasReachedTheEnd = false
            nextPage = 1
        }
        
        API.Posts.getPostsNearby(page: nextPage) { posts, successful in
            if successful {
                if let location = location {
                    for post in posts {
                        post.distanceFromLocation(location)
                    }
                }
                
                if refresh {
                    self.posts = posts
                } else {
                    self.posts += posts
                }
                
                self.hideLoadingView()
                self.postsTableView.reloadData()
            } else {
                self.simpleAlert(title: "Unable to get posts", message: "Please try again later")
            }
            
            if posts.count != 0 {
                self.nextPage++
            } else {
                self.hasReachedTheEnd = true
            }
            
            self.populatingPosts = false
            self.refreshControl.endRefreshing()
        }
    }
    
    
    // Table View Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("postCell", forIndexPath: indexPath) as! PostTableViewCell
        
        cell.post = posts[indexPath.row]
        cell.setupUserProfileButton(indexPath, viewController: self)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
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
            destinationViewController.user = post.author
        }
    }
}







extension PostsFeedViewController {
    
    func setupLocationManager(locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
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














