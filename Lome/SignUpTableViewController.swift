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
        if usernameTextField.valid && passwordTextField.valid && passwordTextField.hasEqualValue(passwordConfirmationTextField) {
            signUpButton.enabled = true
        }
    }
    
    func optionalTextFieldChanged(textField: DesignableTextField) {
        if firstnameTextField.filled && lastnameTextField.filled {
            signUpButton.enabled = true
        } else {
            signUpButton.enabled = false
        }
        
        if firstnameTextField.empty && lastnameTextField.empty {
            signUpButton.enabled = true
        }
        
        if emailAddressTextField.invalid {
            signUpButton.enabled = false
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