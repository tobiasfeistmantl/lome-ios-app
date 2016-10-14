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
        
        [firstnameTextField, lastnameTextField].addTarget(self, action: #selector(EditNameTableViewController.textFieldChanged(_:)), forControlEvents: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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

    func textFieldChanged(_ sender: TFTextField) {
        saveButton.isEnabled = firstnameTextField.valid && lastnameTextField.valid
    }
    
    @IBAction func saveButtonDidTouch(_ sender: UIBarButtonItem) {
        let parameters = [
            "user": [
                "firstname": firstnameTextField.text!,
                "lastname": lastnameTextField.text!
            ]
        ]
        
        API.Users.update(parameters as [String : AnyObject]) { user, successful in
            if successful {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "userAttributesUpdated"), object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.simpleAlert(title: NSLocalizedString("Unable to update name", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
            }
        }
    }
    
}
