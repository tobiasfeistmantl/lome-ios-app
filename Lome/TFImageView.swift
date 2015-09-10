//
//  TFImageView.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import Spring

class TFImageView: DesignableImageView {
    @IBInspectable var circularImage: Bool = false {
        didSet {
            if circularImage {
                layer.cornerRadius = frame.size.width / 2
                clipsToBounds = true
            } else {
                layer.cornerRadius = 0
                clipsToBounds = false
            }
        }
    }
}