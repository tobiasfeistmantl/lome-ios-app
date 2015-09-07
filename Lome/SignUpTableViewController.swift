//
//  SignUpTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring

class SignUpTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var signUpButton: UIBarButtonItem!
    
    @IBOutlet weak var usernameTextField: TFTextField!
    @IBOutlet weak var passwordTextField: TFTextField!
    @IBOutlet weak var passwordConfirmationTextField: TFTextField!
    
    @IBOutlet weak var firstnameTextField: TFTextField!
    @IBOutlet weak var lastnameTextField: TFTextField!
    @IBOutlet weak var emailAddressTextField: TFTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleImage(with: UIImage(named: "Sign Up")!, CGRectMake(0, 0, 117.5, 30), navigationItem)
        
        setupRequiredTextFieldTargets()
        setupOptionalTextFieldTargets()
    }
    
    func requiredTextFieldChanged(textField: DesignableTextField) {
        signUpButton.enabled = requiredFieldsValid
    }
    
    func optionalTextFieldChanged(textField: DesignableTextField) {
        if requiredFieldsValid {
            if firstnameTextField.filled {
                signUpButton.enabled = firstnameTextField.valid && lastnameTextField.filled && lastnameTextField.valid && emailAddressTextField.valid
            } else if lastnameTextField.filled {
                signUpButton.enabled = firstnameTextField.valid && firstnameTextField.filled && lastnameTextField.valid && emailAddressTextField.valid
            } else {
                signUpButton.enabled = firstnameTextField.valid && lastnameTextField.valid && emailAddressTextField.valid
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: passwordConfirmationTextField.becomeFirstResponder()
        case passwordConfirmationTextField: firstnameTextField.becomeFirstResponder()
        case firstnameTextField: lastnameTextField.becomeFirstResponder()
        case lastnameTextField: emailAddressTextField.becomeFirstResponder()
        case emailAddressTextField: emailAddressTextField.resignFirstResponder()
        default: textField.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func signUpButtonDidTouch(sender: UIBarButtonItem) {
        // TODO: IMPLEMENTATION PENDING
    }
    
    var requiredFieldsValid: Bool {
        return usernameTextField.valid && passwordTextField.valid && passwordConfirmationTextField.hasEqualValue(passwordTextField)
    }
    
    
    
    func setupRequiredTextFieldTargets() {
        let action: Selector = "requiredTextFieldChanged:"
        let forControlEvents = UIControlEvents.EditingChanged
        
        usernameTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
        passwordTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
        passwordConfirmationTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
    }
    
    func setupOptionalTextFieldTargets() {
        let action: Selector = "optionalTextFieldChanged:"
        let forControlEvents = UIControlEvents.EditingChanged
        
        firstnameTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
        lastnameTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
        emailAddressTextField.addTarget(self, action: action, forControlEvents: forControlEvents)
    }
}