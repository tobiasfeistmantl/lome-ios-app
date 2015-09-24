//
//  UIImage.swift
//  Lome
//
//  Created by Tobias Feistmantl on 22/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
    
    func aspectRatioConstraintForImageView(imageView: UIImageView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: aspectRatio, constant: 0)
    }
    
    func storeImage(imageName: String) -> String? {
        let fileManager = NSFileManager.defaultManager()
        let imagePath = UIImage.cachePath + "/\(imageName).jpg"
        
        let imageData = UIImageJPEGRepresentation(self, 0.8)
        
        if fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil) {
            return imagePath
        }
        
        return nil
    }
    
    class func removeImage(imageName: String) -> Bool {
        let fileManager = NSFileManager.defaultManager()
        let imagePath = cachePath + "/\(imageName).jpg"
        
        do {
            try fileManager.removeItemAtPath(imagePath)
        } catch {
            return false
        }
        
        return true
    }
    
    class var cachePath: String {
        return NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
    }
}