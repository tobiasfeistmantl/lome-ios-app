//
//  UIScrollView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 24/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {
    var almostAtTheEnd: Bool {
        return self.contentOffset.y + self.frame.size.height > self.contentSize.height * 0.8
    }
}