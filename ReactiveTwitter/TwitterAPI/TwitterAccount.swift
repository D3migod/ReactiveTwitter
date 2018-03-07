//
//  TwitterAccount.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 06.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

// logged or not
enum AccountStatus {
    case unavailable
    case authorized(AccessToken)
}

struct TwitterAccount {
    
    fileprivate static let tokenPersistanceKey = "ReactiveTwitter token"
    
    static private var key: String!
    static private var secret: String!
    static public func set(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    var token: String? {
        get {
            return KeyChain.retrieveValue(for: TwitterAccount.tokenPersistanceKey)
        }
        set {
            KeyChain.store(newValue, key: TwitterAccount.tokenPersistanceKey)
        }
    }
    

    
    enum Errors: Error {
        case unableToGetToken, invalidResponse
    }
    
    // MARK: - Properties
    
    // MARK: - Getting the current twitter account
    
    func getTokenRequestSignalProducer() -> SignalProducer<String, NetworkError> {
        var headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"]
        if let authorizationHeader = authorizationHeader(user: TwitterAccount.key, password: TwitterAccount.secret) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        guard let request = TwitterAPI.createRequest(URL(string: "https://api.twitter.com/oauth2/token"),
                                                     parameters: ["grant_type": "client_credentials"],
                                                     headers: headers,
                                                     method: .post) else {
                                                        return SignalProducer<String, NetworkError> { observer, _ in
                                                            observer.send(error: NetworkError.invalidUrl)
                                                        }
        }
        return TwitterAPI.performRequest(by: request)
    }
    
    fileprivate func authorizationHeader(user: String, password: String) -> (key: String, value: String)? {
        guard let data = "\(user):\(password)".data(using: .utf8) else { return nil }
        
        let credential = data.base64EncodedString(options: [])
        
        return (key: "Authorization", value: "Basic \(credential)")
    }
    
    var account: SignalProducer<AccountStatus, NoError> {
        if let token = token {
            return SignalProducer(value: AccountStatus.authorized(token))
        } else {
        return getTokenRequestSignalProducer()
            .flatMapError { _ in
                return SignalProducer<String, NoError>(value: "")
            }
            .map { token in
                token.isEmpty ? AccountStatus.unavailable : AccountStatus.authorized(token)
            }
        }
    }
}
