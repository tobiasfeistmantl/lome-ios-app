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
                setTitleColor(UIColor(hex: "3B5998"), forState: .Normal)
                setImage(UIImage(named: "Facebook Activated"), forState: .Normal)
            } else {
                setTitleColor(UIColor(hex: "9B9B9B"), forState: .Normal)
                setImage(UIImage(named: "Facebook Deactivated"), forState: .Normal)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTarget(self, action: "touched", forControlEvents: .TouchUpInside)
    }
    
    func touched() {
        postOnNetwork = !postOnNetwork
        
        if FBSDKAccessToken.currentAccessToken() == nil {
            FBSDKLoginManager().logInWithPublishPermissions(["publish_actions"], fromViewController: viewController) { result, _ in
                self.postOnNetwork = false
            }
        }
    }
}