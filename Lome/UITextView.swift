//
//  UITextView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    var placeholder: String? {
        get {
            if textColor == UIColor.grayColor() {
                return text
            }
            
            return nil
        }
        
        set {
            if let newValue = newValue {
                text = newValue
                textColor = .grayColor()
            } else {
                text = ""
                textColor = .blackColor()
            }
        }
    }
    
    var empty: Bool {
        return text == ""
    }
}