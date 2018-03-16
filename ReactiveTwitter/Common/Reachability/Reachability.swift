//
//  Reachability.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 07.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import SystemConfiguration
import ReactiveSwift
import Result

public class Reachability {
    
    // MARK: - Functions
    
    /**
     SignalProducer emitting single isConnected boolean value 
     
     - Returns: Authorization key-value header
     */
    public static func isConnected() -> SignalProducer<Bool, NoError> {
        
        var zeroAddress = sockaddr_in() // Initialize socketAddress (C struct) with zeros
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress)) // Setup size of the structure
        zeroAddress.sin_family = sa_family_t(AF_INET) // Convert Int32 to __uint8_t
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, { // Pass the address to SCNetworkReachability constructor
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { // Convert to a sockaddr's pointer
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return SignalProducer(value: false)
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) { // Retrieve flags
            return SignalProducer(value: false)
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return SignalProducer(value:isReachable && !needsConnection)
    }
}
