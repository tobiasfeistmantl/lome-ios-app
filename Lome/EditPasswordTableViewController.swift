//
//  EditPasswordTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class EditPasswordTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var passwordTextField: TFTextField!
    @IBOutlet weak var passwordConfirmationTextField: TFTextField!

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [passwordTextField, passwordConfirmationTextField].addTarget(self, action: #selector(EditPasswordTableViewController.textFieldChanged(_:)), forControlEvents: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textField = textField as! TFTextField
        
        if textField.valid {
            switch textField {
            case passwordTextField: passwordConfirmationTextField.becomeFirstResponder()
            case passwordConfirmationTextField: passwordConfirmationTextField.resignFirstResponder()
            default: textField.resignFirstResponder()
            }
        } else {
            textField.setInlineErrorMessageByValidationError()
        }
        
        return true
    }
    
    func textFieldChanged(_ sender: TFTextField) {
        saveButton.isEnabled = passwordTextField.valid && passwordConfirmationTextField.hasEqualValue(passwordTextField)
    }
    
    
    @IBAction func saveButtonDidTouch(_ sender: UIBarButtonItem) {
        let parameters = [
            "user": [
                "password": passwordTextField.text!
            ]
        ]
        
        API.Users.update(parameters as [String : AnyObject]) { _, successful in
            if successful {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.simpleAlert(NSLocalizedString("Unable to update password", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
}
