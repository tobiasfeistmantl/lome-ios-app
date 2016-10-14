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
import FBSDKShareKit
import imglyKit

class MessageComposerViewController: UIViewController, UITextViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var postPositionMapView: MKMapView!
    @IBOutlet weak var messageTextView: DesignableTextView!
    @IBOutlet weak var postButton: DesignableButton!
    
    @IBOutlet weak var messageComposerView: UIView!
    @IBOutlet weak var messageComposerViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takeImageButton: UIButton!
    
    @IBOutlet weak var chosenImageView: UIImageView!
    
    @IBOutlet weak var postingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var facebookShareButton: TFSocialButton!
    
    var post: Post?
    var imageUploading = false
    var postButtonTouched = false
    var alreadyZoomedToUserLocation = false
    
    var placeholderSetInMessageTextView = true
    var placeholderText = NSLocalizedString("Your message here...", comment: "Your message here...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookShareButton.viewController = self
        
        setupObserversForKeyboard()
        messageTextView.placeholder = placeholderText
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if alreadyZoomedToUserLocation {
            return
        }
        
        mapView.zoomToPosition(userLocation.coordinate, 100, 100)
        alreadyZoomedToUserLocation = true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if placeholderSetInMessageTextView {
            placeholderSetInMessageTextView = false
            messageTextView.placeholder = nil
        }
        
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func postButtonDidTouch(_ sender: DesignableButton) {
        messageTextView.resignFirstResponder()
        
        postButtonTouched = true
        
        if !imageUploading {
            publishPost()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonDidTouch(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
        if let post = post {
            let URL = API.baseURLString + "/users/\(post.author.id)/posts/\(post.id)"
            
            Alamofire.request(.DELETE, URL, headers: API.defaultSignedInHeaders)
        }
    }
    
    
    func keyboardWillShow() {
        moveMessageComposerView(up: true)
    }
    
    func keyboardWillHide() {
        moveMessageComposerView(up: false)
    }
    
    func moveMessageComposerView(up: Bool) {
        view.layoutIfNeeded()
        
        if up {
            let screen = UIScreen.main.bounds
            
            switch screen.height {
            case 480: messageComposerViewCenterYConstraint.constant = 180
            case 568: messageComposerViewCenterYConstraint.constant = 170
            default: messageComposerViewCenterYConstraint.constant = 120
            }
            
        } else {
            messageComposerViewCenterYConstraint.constant = 0
        }
        
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func takePhotoButtonDidTouch(_ sender: UIButton) {
        let cameraViewController = CameraViewController(recordingModes: [.Photo])
        cameraViewController.completionBlock = { image, url in
            let editorViewController = IMGLYMainEditorViewController()
            editorViewController.highResolutionImage = image
            editorViewController.completionBlock = { result, image in
                self.chosenImageView.image = image
                
                if let image = image {
                    self.imageUploading = true

                    API.Users.Posts.uploadImage(image) { post, successful in
                        self.post = post
                        self.imageUploading = false
                        
                        if successful {
                            if self.postButtonTouched {
                                self.publishPost()
                            }
                        } else {
                            self.simpleAlert(title: NSLocalizedString("Unable to upload image", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
                        }
                        
                    }
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            let navigationController = IMGLYNavigationController(rootViewController: editorViewController)
            navigationController.navigationBar.barStyle = .Black
            navigationController.navigationBar.translucent = false
            navigationController.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
            
            cameraViewController.presentViewController(navigationController, animated: true, completion: nil)
        }
        
        presentViewController(cameraViewController, animated: true, completion: nil)
    }
    
    func publishPost() {
        let URL: String
        let method: Alamofire.Method
        
        if let post = post {
            URL = "/users/\(post.author.id)/posts/\(post.id)"
            method = .PATCH
        } else {
            URL = "/users/\(UserSession.currentUser!.id)/posts"
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
        
        if facebookShareButton.postOnNetwork && FBSDKAccessToken.current().hasGranted("publish_actions") {
            if let image = chosenImageView.image {
                let photo = FBSDKSharePhoto(image: image, userGenerated: true)
                
                let content = FBSDKSharePhotoContent()
                content.photos = [photo]
                
                let fbAPI = FBSDKShareAPI()
                fbAPI.message = message
                fbAPI.shareContent = content
                fbAPI.share()
            } else {
                let graphRequest = FBSDKGraphRequest(graphPath: "me/feed", parameters: ["message": message], httpMethod: "POST")
                graphRequest?.start(completionHandler: nil)
            }
        }
        
        dispatch_get_global_queue(DispatchQueue.GlobalQueuePriority.background, 0).async {
            API.request(method, URL, parameters: parameters, headers: API.defaultSignedInHeaders).validate().responseJSON { serverResponse in
                let result = serverResponse.result
                dispatch_async(dispatch_get_main_queue()) {
                    switch result {
                    case .Success:
                        break
                    case .Failure:
                        UIApplication.sharedApplication().keyWindow?.rootViewController!.simpleAlert(title: NSLocalizedString("Unable to post", comment: ""), message: NSLocalizedString("Please try again later", comment: ""))
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupObserversForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposerViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MessageComposerViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}














