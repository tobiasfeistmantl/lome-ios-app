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
import CoreLocation

struct UserSession {
    static let keychain = Keychain(service: "com.lomeapp.session")
    static var currentLocation: CLLocation?
    
    static var currentUser: Lome.User? {
        get {
            var id: Int? = nil
            let username = keychain["user_username"]
            var role: UserRole? = nil
        
            if let userId = keychain["user_id"] {
                id = Int(userId)
            }
        
            if let userRole = keychain["user_role"] {
                role = UserRole(rawValue: Int(userRole)!)
            }
        
            if id != nil && username != nil && role != nil {
                return Lome.User(id: id!, firstname: nil, lastname: nil, username: username!, followerCount: 0, profileImageAspectRatio: 0, profileImageURLs: [:], following: false, role: role!)
            }
        
            return nil
        }
        
        set {
            let u = newValue
            
            if let u = u {
                keychain["user_id"] = "\(u.id)"
                keychain["user_username"] = u.username
                keychain["user_role"] = "\(u.role.rawValue)"
            } else {
                keychain["user_id"] = nil
                keychain["user_username"] = nil
                keychain["user_role"] = nil
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
            if newValue != nil {
                keychain["id"] = "\(newValue!)"
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
    
    static var signedIn: Bool {
        return id != nil && token != nil && currentUser != nil
    }
    
    static func delete() {
        id = nil
        token = nil
        currentUser = nil
    }
}




