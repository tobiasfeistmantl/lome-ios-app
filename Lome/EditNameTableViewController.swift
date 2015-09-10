//
//  EditNameTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class EditNameTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var firstnameTextField: TFTextField!
    @IBOutlet weak var lastnameTextField: TFTextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        [firstnameTextField, lastnameTextField].addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let textField = textField as! TFTextField
        
        if textField.valid {
            switch textField {
            case firstnameTextField: lastnameTextField.becomeFirstResponder()
            case lastnameTextField: lastnameTextField.resignFirstResponder()
            default: textField.resignFirstResponder()
            }
        } else {
            textField.setInlineErrorMessageByValidationError()
        }
        
        return true
    }

    func textFieldChanged(sender: TFTextField) {
        saveButton.enabled = firstnameTextField.valid && lastnameTextField.valid
    }
    
    @IBAction func saveButtonDidTouch(sender: UIBarButtonItem) {
        // TODO: IMPLEMENTATION PENDING
    }
    
}
