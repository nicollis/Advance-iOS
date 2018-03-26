//
//  GithubKeychain.swift
//  SurelyYouGist
//
//  Created by Michael Ward on 10/10/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Security

let GithubKeychainService = "com.bignerdranch.github.oauth"

class GithubKeychain: NSObject {
    
    class func storeToken(_ token:String?) -> Bool {
        print("Storing token in keychain")
        
        _ = forgetToken()
        
        guard let token = token, let tokenData = token.data(using: String.Encoding.utf8,
                                                        allowLossyConversion: false)
            else {
                print("Failed to store token; no/invalid token provided")
                return false
        }
        
        let itemQuery: [CFString:CFTypeRef] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: GithubKeychainService as CFString,
            kSecValueData: tokenData as CFData
        ]
        
        let status = SecItemAdd(itemQuery as CFDictionary, nil)
        
        switch status {
        case errSecSuccess:
            print("Stored token in keychain")
            return true
        case -34018:  // errSecMissingEntitlement
            // https://forums.developer.apple.com/thread/51071
            print("\n\n**********")
            print("You're being bitten by an iOS10 Simulator / Xcode 8 bug (error code \(status)).")
            print("The workaround is to enable Keychain Sharing")
            print("**********\n\n")
            return false
        default:
            print("ERROR: Failed to store token \(token), code \(status)")
            return false
        }
    }
    
    class func token() -> String? {
        print("Fetching token from keychain")
        let query: [CFString:CFTypeRef] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: GithubKeychainService as CFString,
            kSecReturnData: true as CFNumber
        ]
        
        var cfTypeResult: CFTypeRef? = nil // should be a Data-encoded String
        let status = SecItemCopyMatching(query as CFDictionary, &cfTypeResult)
        
        switch status {
        case errSecSuccess:
            if let tokenData = cfTypeResult as? Data,
                let token = NSString(data: tokenData, encoding: String.Encoding.utf8.rawValue) {
                    print("Found token in keychain: \(token)")
                    return token as String?
            } else {
                print("Failed to get the data: \(String(describing: cfTypeResult)), status: \(status)")
                return nil
            }
        case errSecItemNotFound:
            print("No token found, returning nil")
            return nil
        default:
            print("Failed to fetch token; keychain error \(status)")
            return nil
        }
    }
    
    class func forgetToken() -> Bool {
        let query: [NSString:NSString] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: GithubKeychainService as NSString,
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess, errSecItemNotFound:
            print("Token deleted or already gone")
            return true
        default:
            print("Failed to fetch token; keychain error \(status)")
            return false
        }
    }
    
}
