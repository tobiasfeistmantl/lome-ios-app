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
    func simpleAlert(_ title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    class var topMost: UIViewController {
        var topController = UIApplication.shared.keyWindow?.rootViewController
        
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
        }
        
        return topController!
    }
    
    func showNoLocationAccessAlert() {
        let alert = UIAlertController(title: NSLocalizedString("We don't have access to your location!", comment: ""), message: NSLocalizedString("To show posts near your location we need to have access to your current location.", comment: ""), preferredStyle: .actionSheet)
        
        alert.addAction(
            UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (action: UIAlertAction!) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
