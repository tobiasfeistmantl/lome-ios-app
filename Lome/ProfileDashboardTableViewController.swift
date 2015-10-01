//
//  ProfileDashboardTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class ProfileDashboardTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User!
    
    @IBOutlet weak var userProfileImageView: TFImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "assignUpdatedUserAttributes", name: "userAttributesUpdated", object: nil)
        
        assignUserAttributes()
    }
    
    func assignUpdatedUserAttributes() {
        API.request(.GET, "/users/\(UserSession.User.id!)", headers: API.defaultSignedInHeaders).responseJSON { _, _, result in
            if let value = result.value {
                dispatch_async(dispatch_get_main_queue()) {
                    self.user = User(data: JSON(value))
                    self.assignUserAttributes()
                }
            }
        }
    }
    
    func assignUserAttributes() {
        if let imageURLString = user.profileImageURLs[.Thumbnail] {
            let imageURL = NSURL(string: imageURLString)!
            
            userProfileImageView.af_setImageWithURL(imageURL)
        }
        
        usersNameLabel.text = user.fullName
        emailLabel.text = user.email
        usernameLabel.text = user.username
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let identifier = cell?.reuseIdentifier {
            switch identifier {
            case "changeProfileImageCell":
                changeProfileImage()
            case "deleteSessionCell":
                API.Users.signOut(nil)
                
                let viewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                
                presentViewController(viewController!, animated: true, completion: nil)
            case "deleteAccountCell":
                presentViewController(destroyAccountAlertController, animated: true, completion: nil)
            default: break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func changeProfileImage() {
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        userProfileImageView.image = image
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let imagePath = image.storeImage("tmpProfileImage")
            let imageURL = NSURL.fileURLWithPath(imagePath!)
            
            let URL = API.baseURLString + "/users/\(self.user.id)"
            
            Alamofire.upload(.PATCH, URL, headers: API.defaultSignedInHeaders, multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(fileURL: imageURL, name: "user[profile_image]")
                }) { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.validate().responseJSON { _, _, result in
                            switch result {
                            case .Success:
                                NSNotificationCenter.defaultCenter().postNotificationName("userUpdated", object: nil)
                            case .Failure:
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.simpleAlert(title: "Unable to update profile image", message: "Please try again later")
                                }
                            }
                        }
                    case .Failure:
                        dispatch_async(dispatch_get_main_queue()) {
                            self.simpleAlert(title: "Unable to process profile image", message: "Upload cancelled")
                        }
                    }
                    
                    UIImage.removeImage("tmpProfileImage")
            }
        }
    }
    
    
    var destroyAccountAlertController: UIAlertController {
        let alert = UIAlertController(title: "Delete Account", message: "Do you really want to delete your account? This action is irreversible!", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete my Account 😢", style: .Destructive, handler: deleteUser)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        for action in [deleteAction, cancelAction] {
            alert.addAction(action)
        }
        
        return alert
    }
    
    func deleteUser(action: UIAlertAction) {
        
        API.request(.DELETE, "/users/\(UserSession.User.id!)", headers: API.defaultSignedInHeaders).responseJSON { _, response, _ in
            if response?.statusCode == 204 {
                dispatch_async(dispatch_get_main_queue()) {
                    UserSession.delete()
                    
                    let viewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                    
                    self.presentViewController(viewController!, animated: true, completion: nil)
                    
                    self.simpleAlert(title: "Bye Bye", message: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.simpleAlert(title: "Unable to delete account", message: "Please try again later")
                }
            }
        }
    }
}
