//
//  EditNameTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Alamofire

class EditNameTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var firstnameTextField: TFTextField!
    @IBOutlet weak var lastnameTextField: TFTextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        [firstnameTextField, lastnameTextField].addTarget(self, action: #selector(EditNameTableViewController.textFieldChanged(_:)), forControlEvents: .EditingChanged)
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
        let parameters = [
            "user": [
                "firstname": firstnameTextField.text!,
                "lastname": lastnameTextField.text!
            ]
        ]
        
        API.Users.update(parameters) { user, successful in
            if successful {
                NSNotificationCenter.defaultCenter().postNotificationName("userAttributesUpdated", object: nil)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to update name", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
    
}
