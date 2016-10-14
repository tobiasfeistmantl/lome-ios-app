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
    func setTitleImage(_ image: UIImage, height: CGFloat = 27) {
        let imageAspectRatio = image.size.width / image.size.height
        
        let width = height * imageAspectRatio
        
        let navigationRectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        let navigationImage = UIImageView(frame: navigationRectangle)
        navigationImage.image = image
        
        let workaroundImageView = UIImageView(frame: navigationRectangle)
        workaroundImageView.addSubview(navigationImage)
        
        self.titleView = workaroundImageView
    }
}
