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
        
        emailAddressTextField.addTarget(self, action: #selector(EditEmailAddressTableViewController.textFieldChanged(_:)), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textField = textField as! TFTextField
        
        if textField.valid {
            emailAddressTextField.resignFirstResponder()
        } else {
            textField.setInlineErrorMessageByValidationError()
        }
        
        return true
    }
    
    func textFieldChanged(_ sender: TFTextField) {
        saveButton.isEnabled = emailAddressTextField.valid
    }
    
    @IBAction func saveButtonDidTouch(_ sender: UIBarButtonItem) {
        let parameters = [
            "user": [
                "email": emailAddressTextField.text!
            ]
        ]
        
        API.Users.update(parameters as [String : AnyObject]) { _, successful in
            if successful {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userAttributesUpdated"), object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to update email address", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
    
}
