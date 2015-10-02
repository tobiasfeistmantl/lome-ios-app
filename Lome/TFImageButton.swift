//
//  TFImageButton.swift
//  Lome
//
//  Created by Tobias Feistmantl on 02/10/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import UIKit
import JTSImageViewController

class TFImageButton: UIButton {
    func showImage(image: UIImage) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = image
        imageInfo.referenceRect = self.frame;
        imageInfo.referenceView = self.superview;
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        
        imageViewer.showFromViewController(UIApplication.sharedApplication().keyWindow?.rootViewController, transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
}