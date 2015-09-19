//
//  PostTableViewCell.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    var post: Post!
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
}
