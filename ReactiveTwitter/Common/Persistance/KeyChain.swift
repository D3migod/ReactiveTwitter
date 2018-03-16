//
//  KeyChain.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 06.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

public class KeyChain {
    
    /**
     Saves data in KeyChain
     
     - Parameter key: key to store data by
     
     - Parameter data: data to store
     
     - Returns: store result error-code
     */
    fileprivate static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    /**
     Returns data stored in KeyChain by key 'key'
     
     - Parameter key: key data is stored by
     
     - Returns: data stored in KeyChain
     */
    fileprivate static func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    /**
     Deletes data stored by key
     
     - Parameter key: key data is stored by
     */
    fileprivate static func delete(key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key] as [String : Any]
        SecItemDelete(query as CFDictionary)
    }
    
    /**
     Public function that deletes data stored by key
     
     - Parameter key: key data is stored by
     */
    public static func deleteValue(for key: String) {
        delete(key: key)
    }
    
    /**
     Stores String value by key
     
     - Parameter value: string to store in KeyChain
     
     - Parameter key: key to store data by
     */
    public static func store(_ value: String?, key: String) {
        guard let data = value?.data(using: .utf8) else {
            delete(key: key)
            return
        }
        let _ = KeyChain.save(key: key, data: data)
    }
    
    /**
     Returns string stored in KeyChain by key 'key'
     
     - Parameter key: key data is stored by
     
     - Returns: string stored in KeyChain
     */
    public static func retrieveValue(for key: String) -> String? {
        guard let receivedData = KeyChain.load(key: key) else { return nil }
        return String(data: receivedData, encoding: .utf8) as String!
    }
}
