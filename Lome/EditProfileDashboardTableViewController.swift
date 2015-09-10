//
//  EditProfileDashboardTableViewController.swift
//  Lome
//
//  Created by Tobias Feistmantl on 09/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import UIKit

class EditProfileDashboardTableViewController: UITableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if let identifier = cell?.reuseIdentifier {
            switch identifier {
            case "deleteSessionCell":
                break // TODO: IMPLEMENTATION PENDING
            case "deleteAccountCell":
                presentViewController(destroyAccountAlertController(), animated: true, completion: nil)
            default: break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    func destroyAccountAlertController() -> UIAlertController {
        let alert = UIAlertController(title: "Delete Account", message: "Do you really want to delete your account? This action is irreversible!", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete my Account 😢", style: .Destructive, handler: nil) // TODO: IMPLEMENTATION PENDING
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        for action in [deleteAction, cancelAction] {
            alert.addAction(action)
        }
        
        return alert
    }
}
