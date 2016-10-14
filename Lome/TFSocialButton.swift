//
//  TFSocialButton.swift
//  Lome
//
//  Created by Tobias Feistmantl on 08/10/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class TFSocialButton: UIButton {
    var viewController: UIViewController?
    
    var postOnNetwork = false {
        didSet {
            if postOnNetwork {
                setTitleColor(UIColor(hex: "3B5998"), for: .Normal)
                setImage(UIImage(named: "Facebook Activated"), for: UIControlState())
            } else {
                setTitleColor(UIColor(hex: "9B9B9B"), for: .Normal)
                setImage(UIImage(named: "Facebook Deactivated"), for: UIControlState())
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: #selector(TFSocialButton.touched), for: .touchUpInside)
    }
    
    func touched() {
        postOnNetwork = !postOnNetwork
        
        if FBSDKAccessToken.current() == nil {
            FBSDKLoginManager().logIn(withPublishPermissions: ["publish_actions"], from: viewController) { result, _ in
                self.postOnNetwork = false
            }
        }
    }
}
