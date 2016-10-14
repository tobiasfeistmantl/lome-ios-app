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
    
    func storeImage(_ imageName: String) -> String? {
        let fileManager = FileManager.default
        let imagePath = UIImage.cachePath + "/\(imageName).jpg"
        
        let imageData = UIImageJPEGRepresentation(UIImage.fixOrientation(self), 0.8)
        
        if fileManager.createFile(atPath: imagePath, contents: imageData, attributes: nil) {
            return imagePath
        }
        
        return nil
    }
    
    class func removeImage(_ imageName: String) -> Bool {
        let fileManager = FileManager.default
        let imagePath = cachePath + "/\(imageName).jpg"
        
        do {
            try fileManager.removeItem(atPath: imagePath)
        } catch {
            return false
        }
        
        return true
    }
    
    class var cachePath: String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    }
    
    class func fixOrientation(_ image: UIImage) -> UIImage {
        
        if (image.imageOrientation == UIImageOrientation.up) {
            return image;
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        image.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    class func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
