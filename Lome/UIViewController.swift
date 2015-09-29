//
//  UIViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func simpleAlert(title title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    class var topMost: UIViewController {
        var topController = UIApplication.sharedApplication().keyWindow?.rootViewController
        
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
        }
        
        return topController!
    }
}