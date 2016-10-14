//
//  UserTableViewCell.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    var user: User! {
        didSet {
            if let name = user.fullName {
                usersNameLabel.text = name
                usernameLabel.text = user.username
            } else {
                usersNameLabel.text = user.username
                usernameLabel.isHidden = true
            }
            
            followerCountLabel.text = user.followerCountText
            
            user.profileImage(version: .Thumbnail) { image, _ in
                self.userProfileImageView.image = image
            }
        }
    }
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
