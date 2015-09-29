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
    func aspectRatioConstraintForMultiplier(multiplier: Double) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: CGFloat(multiplier), constant: 0)
        constraint.priority = 999
        
        return constraint
    }
}