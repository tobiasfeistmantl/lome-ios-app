//
//  String.swift
//  Lome
//
//  Created by Tobias Feistmantl on 10/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation

extension String {
    
    // Returns true if the string is an email address
    var emailFormat: Bool {
        return NSPredicate(format:"SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    
    // Returns true if the string is an username
    var usernameFormat: Bool {
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluateWithObject(self)
    }
}