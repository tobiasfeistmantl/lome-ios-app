//
//  Utilities.swift
//  Lome
//
//  Created by Tobias Feistmantl on 06/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation



var railsDateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    
    return dateFormatter
}
