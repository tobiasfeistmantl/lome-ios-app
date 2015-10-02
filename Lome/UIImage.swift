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
    
    func storeImage(imageName: String) -> String? {
        let fileManager = NSFileManager.defaultManager()
        let imagePath = UIImage.cachePath + "/\(imageName).jpg"
        
        let imageData = UIImageJPEGRepresentation(UIImage.fixOrientation(self), 0.8)
        
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
    
    class func fixOrientation(image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.Up) {
            return image;
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.drawInRect(rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}