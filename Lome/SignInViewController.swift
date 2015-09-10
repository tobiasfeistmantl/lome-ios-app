//
//  SignInViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var signInViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signInView: DesignableView!
    
    @IBOutlet weak var usernameTextField: TFTextField!
    @IBOutlet weak var passwordTextField: TFTextField!
    @IBOutlet weak var signInButton: DesignableButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
        
        [usernameTextField, passwordTextField].addTarget(self, action: "textFieldChanged:", forControlEvents: .EditingChanged)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func signInButtonDidTouch(sender: DesignableButton) {
        // TODO: IMPLEMENTATION PENDING
        shakeSignInView()
    }
    
    func textFieldChanged(textField: DesignableTextField) {
        if usernameTextField.valid && passwordTextField.valid {
            signInButton.enabled = true
        } else {
            signInButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField:
            passwordTextField.resignFirstResponder()
            signInButtonDidTouch(signInButton)
        default: textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    func keyboardWillShow() {
        moveSignInView(up: true)
    }
    
    func keyboardWillHide() {
        moveSignInView(up: false)
    }

    func moveSignInView(#up: Bool) {
        view.layoutIfNeeded()
        
        if up {
            let screen = UIScreen.mainScreen().bounds
            
            switch screen.height {
            case 480: signInViewCenterYConstraint.constant = 135
            case 568: signInViewCenterYConstraint.constant = 100
            default: signInViewCenterYConstraint.constant = 75
            }
            
        } else {
            signInViewCenterYConstraint.constant = 0
        }
        
        UIView.animateWithDuration(1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func shakeSignInView() {
        signInView.animation = "shake"
        signInView.animate()
    }
}

















