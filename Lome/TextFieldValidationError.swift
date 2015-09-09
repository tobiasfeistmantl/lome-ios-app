//
//  TextFieldValidationError.swift
//  Lome
//
//  Created by Tobias Feistmantl on 07/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation

enum TextFieldValidationError: String {
    case Empty = "The field is empty"
    case TooShort = "The value is too short"
    case TooLong = "The value is too long"
    case InvalidUsername = "This isn't a valid username"
    case InvalidEmailAddress = "This isn't a valid email address"
}