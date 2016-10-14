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
    @IBInspectable var circularButton: Bool = false {
        didSet {
            if circularButton {
                layer.cornerRadius = frame.size.width / 2
            }
        }
    }
    
    func showImage(_ image: UIImage) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = image
        imageInfo.referenceRect = self.frame
        imageInfo.referenceView = self.superview
        
        if circularButton {
            imageInfo.referenceCornerRadius = frame.size.width / 2
        }
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: .image, backgroundStyle: .blurred)
        
        imageViewer?.show(from: UIApplication.shared.keyWindow?.rootViewController, transition: JTSImageViewControllerTransition.fromOriginalPosition)
    }
}
