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

class PostsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, CLLocationManagerDelegate, TFInfiniteScroll {
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
    var populatingAtTheMoment = false
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(PostsFeedViewController.refreshPosts), for: .valueChanged)
        postsTableView.addSubview(refreshControl)
        
        showLoadingView(NSLocalizedString("Loading posts near your location", comment: ""))
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "Lome for colored Background without Shadow iOS Navbar")!)
        setupLocationManager(locationManager)
        setupTableView(postsTableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data to recognize if post has been liked
        postsTableView.reloadData()
    }
    
    func refreshPosts() {
        locationManager.startUpdatingLocation()
    }
    
    
    // Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            if CLLocationManager.authorizationStatus() != .notDetermined {
                showNoLocationAccessAlert()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        location = locations.last
        
        API.Users.Positions.update(location!) { successful in
            if successful {
                self.populate(true)
            } else {
                self.simpleAlert(NSLocalizedString("Unable to update your location", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
                self.refreshControl.endRefreshing()
                self.hideLoadingView()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if location == nil || hasReachedTheEnd || populatingAtTheMoment {
            return
        }
        
        if scrollView.almostAtTheEnd {
            populate()
        }
    }
    
    func populate(_ reload: Bool = false) {
        populatingAtTheMoment = true
        
        if reload {
            hasReachedTheEnd = false
            nextPage = 1
        }
        
        API.Posts.getPostsNearby(page: nextPage) { posts, successful in
            if successful {
                if let location = self.location {
                    for post in posts {
                        post.distanceFromLocation(location)
                    }
                }
                
                if reload {
                    self.posts = posts
                } else {
                    self.posts += posts
                }
                
                self.postsTableView.reloadData()
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to get posts", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
            
            if posts.count != 0 {
                self.nextPage += 1
            } else {
                self.hasReachedTheEnd = true
            }
            
            self.populatingAtTheMoment = false
            self.refreshControl.endRefreshing()
            self.hideLoadingView()
        }
    }
    
    
    // Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
        
        cell.post = posts[(indexPath as NSIndexPath).row]
        cell.setupUserProfileButton(indexPath, viewController: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        performSegue(withIdentifier: "showPost", sender: cell)
    }
    
    func userProfileButtonDidTouch(_ sender: TFCellButton) {
        performSegue(withIdentifier: "showUserProfileFromCell", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPost" {
            let cell = (sender as! PostTableViewCell)
            let post = cell.post
            let destinationViewController = segue.destination as! PostViewController
            
            destinationViewController.post = post
        }
        
        if segue.identifier == "showUserProfile" {
            let destinationViewController = segue.destination as! ProfileTableViewController
            destinationViewController.userId = UserSession.currentUser!.id
        }
        
        if segue.identifier == "showUserProfileFromCell" {
            let button = sender as! TFCellButton
            let post = posts[(button.indexPath! as IndexPath).row]
            
            let destinationViewController = segue.destination as! ProfileTableViewController
            destinationViewController.user = post.author
        }
    }
}







extension PostsFeedViewController {
    
    func setupLocationManager(_ locationManager: CLLocationManager) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func setupTableView(_ tableView: UITableView) {
        postsTableView.register(UINib(nibName: "PostTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "postCell")
        postsTableView.estimatedRowHeight = 301
        postsTableView.rowHeight = UITableViewAutomaticDimension
    }
}














