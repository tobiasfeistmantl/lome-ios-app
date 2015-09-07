//
//  TextFieldValidationError.swift
//  Lome
//
//  Created by Tobias Feistmantl on 07/09/15.
//  Copyright (c) 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation

enum TextFieldValidationError {
    case Empty
    case TooShort
    case TooLong
    case InvalidEmailAddress
}