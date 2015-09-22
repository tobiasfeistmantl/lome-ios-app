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
        
        [passwordTextField, passwordConfirmationTextField].addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
    
    func textFieldChanged(sender: TFTextField) {
        saveButton.enabled = passwordTextField.valid && passwordConfirmationTextField.hasEqualValue(passwordTextField)
    }
    
    
    @IBAction func saveButtonDidTouch(sender: UIBarButtonItem) {
        // TODO: IMPEMENTATION PENDING
    }
}
