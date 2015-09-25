//
//  UIImageView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 22/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func constraintWithAspectRatio(aspectRatio: Double) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: CGFloat(aspectRatio), constant: 0)
    }
}