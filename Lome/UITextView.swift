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
            if textColor == UIColor.gray {
                return text
            }
            
            return nil
        }
        
        set {
            if let newValue = newValue {
                text = newValue
                textColor = .gray()
            } else {
                text = ""
                textColor = .black()
            }
        }
    }
    
    var empty: Bool {
        return text == ""
    }
}
