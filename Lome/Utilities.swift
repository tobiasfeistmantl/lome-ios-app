//
//  Utilities.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
let usernameRegex = "(?![-_.])(?!.*[-_.]{2})[a-zA-Z0-9._-]+(?<![-_.])"






func setTitleImage(with image: UIImage, rect: CGRect, navigationItem: UINavigationItem) {
    let navigationRectangle = rect
    
    let navigationImage = UIImageView(frame: navigationRectangle)
    navigationImage.image = image
    
    let workaroundImageView = UIImageView(frame: navigationRectangle)
    workaroundImageView.addSubview(navigationImage)
    
    navigationItem.titleView = workaroundImageView
}



func isValidEmail(testString: String) -> Bool {
    return NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluateWithObject(testString)
}



func isValidUsername(testString: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(testString)
}



func showSimpleAlertWithTitle(title: String!, #message: String, #viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
    alert.addAction(action)
    viewController.presentViewController(alert, animated: true, completion: nil)
}