//
//  Utilities.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

func setTitleImage(with image: UIImage, rect: CGRect, navigationItem: UINavigationItem) {
    let navigationRectangle = rect
    
    let navigationImage = UIImageView(frame: navigationRectangle)
    navigationImage.image = image
    
    let workaroundImageView = UIImageView(frame: navigationRectangle)
    workaroundImageView.addSubview(navigationImage)
    
    navigationItem.titleView = workaroundImageView
}

func isValidEmail(testString: String) -> Bool {
    return NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}").evaluateWithObject(testString)
}

func isValidUsername(testString: String) -> Bool {
    return NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9]+(?:[ _-][A-Za-z0-9]+)*$").evaluateWithObject(testString)
}