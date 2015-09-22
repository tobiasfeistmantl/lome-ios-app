//
//  UIImage.swift
//  Lome
//
//  Created by Tobias Feistmantl on 22/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
    
    func aspectRatioConstraintForImageView(imageView: UIImageView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: aspectRatio, constant: 0)
    }
}