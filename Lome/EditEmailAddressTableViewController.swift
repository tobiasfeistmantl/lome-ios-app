//
//  EditEmailAddressTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class EditEmailAddressTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var emailAddressTextField: TFTextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailAddressTextField.addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let textField = textField as! TFTextField
        
        if textField.valid {
            emailAddressTextField.resignFirstResponder()
        } else {
            textField.setInlineErrorMessageByValidationError()
        }
        
        return true
    }
    
    func textFieldChanged(sender: TFTextField) {
        saveButton.enabled = emailAddressTextField.valid
    }
    
    @IBAction func saveButtonDidTouch(sender: UIBarButtonItem) {
        // TODO: IMPLEMENTATION PENDING
    }
    
}
