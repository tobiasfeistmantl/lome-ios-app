//
//  UINavigationItem.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationItem {
    func setTitleImage(with image: UIImage, rect: CGRect) {
        let navigationRectangle = rect
        
        let navigationImage = UIImageView(frame: navigationRectangle)
        navigationImage.image = image
        
        let workaroundImageView = UIImageView(frame: navigationRectangle)
        workaroundImageView.addSubview(navigationImage)
        
        self.titleView = workaroundImageView
    }
}