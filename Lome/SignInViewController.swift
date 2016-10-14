//
//  SignInViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Spring
import Alamofire
import SwiftyJSON

class SignInViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var signInViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signInView: DesignableView!
    
    @IBOutlet weak var usernameTextField: TFTextField!
    @IBOutlet weak var passwordTextField: TFTextField!
    @IBOutlet weak var signInButton: DesignableButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignInViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        [usernameTextField, passwordTextField].addTarget(self, action: #selector(SignInViewController.textFieldChanged(_:)), forControlEvents: .editingChanged)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func signInButtonDidTouch(_ sender: DesignableButton) {
        API.Users.signIn(usernameTextField.text!, password: passwordTextField.text!) { successful in
            if successful {
                let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                
                self.present(viewController!, animated: true, completion: nil)
            } else {
                self.shakeSignInView()
            }
        }
    }
    
    func textFieldChanged(_ textField: DesignableTextField) {
        if usernameTextField.valid && passwordTextField.valid {
            signInButton.isEnabled = true
        } else {
            signInButton.isEnabled = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
        moveSignInView(true)
    }
    
    func keyboardWillHide() {
        moveSignInView(false)
    }

    func moveSignInView(_ up: Bool) {
        view.layoutIfNeeded()
        
        if up {
            let screen = UIScreen.main.bounds
            
            switch screen.height {
            case 480: signInViewCenterYConstraint.constant = 135
            case 568: signInViewCenterYConstraint.constant = 100
            default: signInViewCenterYConstraint.constant = 75
            }
            
        } else {
            signInViewCenterYConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    func shakeSignInView() {
        signInView.animation = "shake"
        signInView.animate()
    }
}

















