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

class PostsFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var newPostButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postsTableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.setTitleImage(with: UIImage(named: "Lome Red")!, rect: CGRectMake(0, 0, 91, 32))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

}