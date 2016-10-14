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
    
    var errorLabel: UILabel?
    
    var validationError: TFTextFieldValidationError? {
        if mustBePresent && empty {
            return .Empty
        }
        
        if minimumLength != 0 && text!.length < minimumLength && (mustBePresent || filled) {
            return .TooShort
        }
        
        if maximumLength != 0 && text!.length > maximumLength {
            return .TooLong
        }
        
        if isUsername && !text!.usernameFormat && (mustBePresent || filled) {
            return .InvalidUsername
        }
        
        if isEmailAddress && !text!.emailFormat && (mustBePresent || filled) {
            return .InvalidEmailAddress
        }
        
        return nil
    }
    
    
    var valid: Bool {
        if validationError == nil {
            // Always remove error messages if value is valid
            inlineErrorMessage = nil
            
            return true
        } else {
            return false
        }
    }
    
    var invalid: Bool {
        return validationError != nil
    }
    
    var inlineErrorMessage: String? {
        didSet {
            if inlineErrorMessage != nil {
                if errorLabel == nil {
                    let errorColor = UIColor(hex: "AA0000")
                    
                    self.textColor = errorColor
                    
                    self.errorLabel = UILabel()
                    errorLabel!.textColor = errorColor
                    errorLabel!.font = self.font
                    errorLabel!.textAlignment = .Right
                    errorLabel!.translatesAutoresizingMaskIntoConstraints = false
                    
                    errorLabel!.text = inlineErrorMessage
                    
                    self.addSubview(errorLabel!)
                    
                    let centerConstraint = NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: errorLabel, attribute: .CenterY, multiplier: 1, constant: 0)
                    let rightConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: errorLabel, attribute: .Trailing, multiplier: 1, constant: 0)
                    
                    self.addConstraints([centerConstraint, rightConstraint])
                }
            } else {
                textColor = .blackColor()
                errorLabel?.removeFromSuperview()
                errorLabel = nil
            }
        }
    }
    
    func setInlineErrorMessageByValidationError() {
        if let error = validationError {
            inlineErrorMessage = error.rawValue
        }
    }
    
    
    func hasEqualValue(_ textField: UITextField) -> Bool {
        return text == textField.text
    }
    
    
    
    
    var empty: Bool {
        return text == ""
    }
    
    var filled: Bool {
        return text != ""
    }
}
