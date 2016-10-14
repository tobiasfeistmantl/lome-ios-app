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
    func aspectRatioConstraintForMultiplier(_ multiplier: Double) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: CGFloat(multiplier), constant: 0)
        constraint.priority = 999
        
        return constraint
    }
}
