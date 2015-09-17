//
//  UserSession.swift
//  Lome
//
//  Created by Tobias Feistmantl on 16/09/15.
//  Copyright © 2015 Tobias Feistmantl. All rights reserved.
//

import Foundation
import Alamofire
import KeychainAccess

struct UserSession {
    static let keychain = Keychain(service: "com.lomeapp.session")
    
    class User {
        static var id: Int? {
            get {
                if let id = keychain["user_id"] {
                    return Int(id)
                }
                
                return nil
            }
            
            set {
                if let newValue = newValue {
                    keychain["user_id"] = "\(newValue)"
                } else {
                    keychain["user_id"] = nil
                }
            }
        }
        
        static var username: String? {
            get {
                return keychain["user_username"]
            }
            
            set {
                keychain["user_username"] = newValue
            }
        }
    }
    
    static var id: Int? {
        get {
            if let id = keychain["id"] {
                return Int(id)
            }
            
            return nil
        }
        
        set {
            if let newValue = newValue {
                keychain["id"] = "\(newValue)"
            } else {
                keychain["id"] = nil
            }
        }
    }
    
    static var token: String? {
        get {
            return keychain["token"]
        }
        
        set {
            keychain["token"] = newValue
        }
    }
}