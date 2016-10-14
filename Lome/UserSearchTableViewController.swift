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
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "userCell")
        
        populate(reload: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        populate(reload: true)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasReachedTheEnd {
            return
        }
        
        if scrollView.almostAtTheEnd {
            populate()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        
        cell.user = users[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        performSegue(withIdentifier: "showUserProfile", sender: cell)
    }
    
    func populate(reload: Bool = false) {
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
                    self.nextPage += 1
                } else {
                    self.hasReachedTheEnd = true
                }
                
                self.tableView.reloadData()
                self.populatingAtTheMoment = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUserProfile" {
            let cell = sender as! UserTableViewCell
            let destinationViewController = segue.destination as! ProfileTableViewController
            
            destinationViewController.user = cell.user
        }
    }

}
