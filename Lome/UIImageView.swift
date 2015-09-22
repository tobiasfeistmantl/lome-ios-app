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
    func setImageAndAspectRatioForImageView(image: UIImage?) {
        if let image = image {
            self.image = image
            self.addConstraint(image.aspectRatioConstraintForImageView(self))
        }
    }
}