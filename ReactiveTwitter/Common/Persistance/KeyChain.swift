//
//  KeyChain.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 06.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

public class KeyChain {
    fileprivate static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData as String   : data ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
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
    
    fileprivate static func delete(key: String) {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key] as [String : Any]
        SecItemDelete(query as CFDictionary)
    }
    
    public static func store(_ value: String?, key: String) {
        guard let data = value?.data(using: .utf8) else {
            KeyChain.delete(key: key)
            return
        }
        let _ = KeyChain.save(key: key, data: data)
    }
    
    public static func retrieveValue(for key: String) -> String? {
        guard let receivedData = KeyChain.load(key: key) else { return nil }
        return String(data: receivedData, encoding: .utf8) as String!
    }
}
