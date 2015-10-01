//
//  SignUpTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring
import Alamofire
import SwiftyJSON

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
        navigationItem.setTitleImage(UIImage(named: "Sign Up")!, height: 27.5)
        
        [usernameTextField, passwordTextField, passwordConfirmationTextField].addTarget(self, action: "requiredTextFieldChanged:", forControlEvents: .EditingChanged)
        [firstnameTextField, lastnameTextField, emailAddressTextField].addTarget(self, action: "optionalTextFieldChanged:", forControlEvents: .EditingChanged)
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
        let textField = textField as! TFTextField
        
        if textField.valid {
            switch textField {
            case usernameTextField: passwordTextField.becomeFirstResponder()
            case passwordTextField: passwordConfirmationTextField.becomeFirstResponder()
            case passwordConfirmationTextField: firstnameTextField.becomeFirstResponder()
            case firstnameTextField: lastnameTextField.becomeFirstResponder()
            case lastnameTextField: emailAddressTextField.becomeFirstResponder()
            case emailAddressTextField: emailAddressTextField.resignFirstResponder()
            default: textField.resignFirstResponder()
            }
        } else {
            textField.setInlineErrorMessageByValidationError()
        }
        
        return true
    }
    
    @IBAction func signUpButtonDidTouch(sender: UIBarButtonItem) {
        let parameters = [
            "firstname": firstnameTextField.text!,
            "lastname": lastnameTextField.text!,
            "username": usernameTextField.text!,
            "password": passwordTextField.text!
        ]
        
        API.Users.signUp(parameters) { successful, APIError in
            if successful {
            API.Users.signIn(self.usernameTextField.text!, password: self.passwordTextField.text!) { successful in
                if successful {
                    let viewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                    
                    self.presentViewController(viewController!, animated: true, completion: nil)
                }
            }
            } else {
                if let error = APIError {
                    if let usernameError = error["error"]["specific"]["username"][0].string {
                        self.usernameTextField.setInlineErrorMessage(usernameError)
                    }
                } else {
                    self.simpleAlert(title: "An error occurred!", message: "Please check your inserted data")
                }
            }
        }
    }
    
    var requiredFieldsValid: Bool {
        return usernameTextField.valid && passwordTextField.valid && passwordConfirmationTextField.hasEqualValue(passwordTextField)
    }
    
    @IBAction func cancelButtonDidTouch(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}