//
//  KeychainManager.swift
//  Centralis
//
//  Created by AW on 29/12/2020.
//https://stackoverflow.com/a/37539998

import Security
import Foundation

/// The global KeyChainManager, which is a wrapper over Apple's Security framework. This is used for securely storing passwords
public class KeyChainManager {

    /// Save a new key in the keychain, will automatically delete if the key already exists
    /// - Parameters:
    ///   - key: The key it will be saved against
    ///   - data: The data that is being saved
    /// - Returns: The return information. Can usually be ignored. For a list of returns: https://www.osstatus.com
    @discardableResult class public func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecAttrAccessGroup: "group.amywhile.centralis",
            kSecValueData as String   : data ] as! [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Will delete a key that is currently stored in keychain
    /// - Parameter key: The key being deleted
    class public func delete(key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccessGroup: "group.amywhile.centralis",
            kSecAttrAccount as String : key] as [AnyHashable : String]

        SecItemDelete(query as CFDictionary)
    }
    
    /// Retrieve a value stored in the keychain
    /// - Parameter key: The key the value belongs to
    /// - Returns: The value as Data, is nil if the key doesn't exist
    class public func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecAttrAccessGroup: "group.amywhile.centralis",
            kSecMatchLimit as String  : kSecMatchLimitOne ] as! [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
}

