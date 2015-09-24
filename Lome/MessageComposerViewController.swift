//
//  MessageComposerViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import MapKit
import Spring
import Alamofire
import SwiftyJSON

class MessageComposerViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate {
    @IBOutlet weak var postPositionMapView: MKMapView!
    @IBOutlet weak var messageTextView: DesignableTextView!
    @IBOutlet weak var postButton: DesignableButton!
    
    @IBOutlet weak var messageComposerView: UIView!
    @IBOutlet weak var messageComposerViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takeImageButton: UIButton!
    
    @IBOutlet weak var chosenImageView: UIImageView!
    
    @IBOutlet weak var postingActivityIndicator: UIActivityIndicatorView!
    
    var post: Post?
    var imageUploading = false
    var postButtonTouched = false
    
    var placeholderSetInMessageTextView = true
    var placeholderText = "Your message here..."
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takeImageButton.enabled = true
        }
        
        imagePicker.delegate = self
        
        setupObserversForKeyboard()
        messageTextView.placeholder = placeholderText
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        mapView.zoomToPosition(userLocation.coordinate)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if placeholderSetInMessageTextView {
            placeholderSetInMessageTextView = false
            messageTextView.placeholder = nil
        }
        
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func postButtonDidTouch(sender: DesignableButton) {
        postingActivityIndicator.startAnimating()
        postButtonTouched = true
        
        if !imageUploading {
            publishPost()
        }
    }
    
    @IBAction func cancelButtonDidTouch(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if let post = post {
            let URL = baseURLString + "/users/\(post.author.id)/posts/\(post.id)"
            
            Alamofire.request(.DELETE, URL, headers: defaultSignedInHeaders)
        }
    }
    
    
    func keyboardWillShow() {
        moveMessageComposerView(up: true)
    }
    
    func keyboardWillHide() {
        moveMessageComposerView(up: false)
    }
    
    func moveMessageComposerView(up up: Bool) {
        view.layoutIfNeeded()
        
        if up {
            let screen = UIScreen.mainScreen().bounds
            
            switch screen.height {
            case 480: messageComposerViewCenterYConstraint.constant = 180
            case 568: messageComposerViewCenterYConstraint.constant = 170
            default: messageComposerViewCenterYConstraint.constant = 120
            }
            
        } else {
            messageComposerViewCenterYConstraint.constant = 0
        }
        
        UIView.animateWithDuration(1) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func takePhotoButtonDidTouch(sender: UIButton) {
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func chooseImageButtonDidTouch(sender: UIButton) {
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        imageUploading = true
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        chosenImageView.image = image
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let fileManager = NSFileManager.defaultManager()
            let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
            let imagePath = cachePath + "/imageToUpload.jpg"
            
            let imageData = UIImageJPEGRepresentation(image, 0.8)
            
            fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
            
            let imageURL = NSURL.fileURLWithPath(imagePath)
            let URL = baseURLString + "/users/\(UserSession.User.id!)/posts/image"
            
            Alamofire.upload(.POST, URL, headers: defaultSignedInHeaders, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: imageURL, name: "post[image]")
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { _, response, result in
                            if let value = result.value {
                                self.imageUploading = false
                                self.post = Post(data: JSON(value)["post"])
                                
                                if self.postButtonTouched {
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.publishPost()
                                    }
                                }
                            }
                            
                            do {
                                try fileManager.removeItemAtPath(imagePath)
                            } catch {
                                print("Unable to delete temporary image")
                            }
                        }
                    case .Failure:
                        dispatch_async(dispatch_get_main_queue()) {
                            self.simpleAlert(title: "Unable to upload image", message: "Please try again")
                        }
                    }
            })
        }
    }
    
    func publishPost() {
        let URL: String
        let method: Alamofire.Method
        
        if let post = post {
            URL = baseURLString + "/users/\(post.author.id)/posts/\(post.id)"
            method = .PATCH
        } else {
            URL = baseURLString + "/users/\(UserSession.User.id!)/posts"
            method = .POST
        }
        
        var message: String = ""
        
        if !placeholderSetInMessageTextView {
            message = messageTextView.text
        }
        
        let parameters = [
            "post": [
                "message": message,
                "latitude": postPositionMapView.centerCoordinate.latitude,
                "longitude": postPositionMapView.centerCoordinate.longitude,
                "status": "published"
            ]
        ]
        
        Alamofire.request(method, URL, parameters: parameters, headers: defaultSignedInHeaders).validate().responseJSON { _, _, result in
            dispatch_async(dispatch_get_main_queue()) {
                switch result {
                case .Success:
                    self.dismissViewControllerAnimated(true, completion: nil)
                case .Failure:
                    self.postingActivityIndicator.stopAnimating()
                    self.simpleAlert(title: "Unable to post", message: "Please try again")
                }
            }
        }
    }
    
    
    func setupObserversForKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
    }
}














