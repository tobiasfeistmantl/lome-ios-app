//
//  Array.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element : UITextField {
    func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        for textField in self {
            let textField = textField as UITextField
            textField.addTarget(target, action: action, forControlEvents: controlEvents)
        }
    }
}

extension Array {
    var last: Element {
        return self[self.endIndex - 1]
    }
}