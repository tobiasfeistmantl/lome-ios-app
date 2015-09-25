//
//  TFImageInfo.swift
//  Lome
//
//  Created by Tobias Feistmantl on 25/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation

struct TFImageInfo {
    var url: String
    var width: Int
    var height: Int
    var version: ImageVersion?
}

enum ImageVersion: String {
    case Original = "original"
    case Thumbnail = "thumbnail"
}
