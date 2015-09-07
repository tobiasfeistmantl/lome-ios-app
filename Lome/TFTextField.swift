//
//  TFTextField.swift
//  Lome
//
//  Created by Tobias Feistmantl on 07/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import Spring

@IBDesignable class TFTextField: DesignableTextField {
    @IBInspectable var mustBePresent: Bool = false
    @IBInspectable var minimumLength: Int = 0
    @IBInspectable var maximumLength: Int = 0
    @IBInspectable var isUsername: Bool = false
    @IBInspectable var isEmailAddress: Bool = false
    
    var validationError: TextFieldValidationError? {
        if mustBePresent {
            if text == "" {
                return .Empty
            }
        }
        
        if minimumLength != 0 {
            if text.length < minimumLength {
                if mustBePresent {
                    return .TooShort
                } else {
                    if filled {
                        return .TooShort
                    }
                }
            }
        }
        
        if maximumLength != 0 {
            if text.length > maximumLength {
                return .TooLong
            }
        }
        
        if isUsername {
            if !isValidUsername(text) {
                if mustBePresent {
                    return .InvalidUsername
                } else {
                    if filled {
                        return .InvalidUsername
                    }
                }
            }
        }
        
        if isEmailAddress {
            if !isValidEmail(text) {
                if mustBePresent {
                    return .InvalidEmailAddress
                } else {
                    if filled {
                        return .InvalidEmailAddress
                    }
                }
            }
        }
        
        return nil
    }
    
    
    
    var valid: Bool {
        return validationError == nil
    }
    
    var invalid: Bool {
        return validationError != nil
    }
    
    
    
    
    func hasEqualValue(textField: UITextField) -> Bool {
        return text == textField.text
    }
    
    
    
    
    var empty: Bool {
        return text == ""
    }
    
    var filled: Bool {
        return text != ""
    }
}