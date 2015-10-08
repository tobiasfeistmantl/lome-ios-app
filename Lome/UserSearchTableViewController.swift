//
//  UserSearchTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UserSearchTableViewController: UITableViewController, UISearchBarDelegate, TFInfiniteScroll {
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    var users: [User] = []
    
    var nextPage = 1
    var hasReachedTheEnd = false
    var populatingAtTheMoment = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "UserTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "userCell")
        
        populate(reload: true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        populate(reload: true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if hasReachedTheEnd {
            return
        }
        
        if scrollView.almostAtTheEnd {
            populate()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserTableViewCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    func populate(reload reload: Bool = false) {
        if populatingAtTheMoment {
            true
        }
        
        populatingAtTheMoment = true
        
        if reload {
            hasReachedTheEnd = false
            nextPage = 1
        }
        
        API.Users.searchByUsername(userSearchBar.text!, page: nextPage) { users, successful in
            if successful {
                if reload {
                    self.users = users
                } else {
                    self.users += users
                }
                
                if users.count != 0 {
                    self.nextPage++
                } else {
                    self.hasReachedTheEnd = true
                }
                
                self.tableView.reloadData()
                self.populatingAtTheMoment = false
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUserProfile" {
            let cell = sender as! UserTableViewCell
            let destinationViewController = segue.destinationViewController as! ProfileTableViewController
            
            destinationViewController.user = cell.user
        }
    }

}
