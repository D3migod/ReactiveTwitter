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
    
    // logged or not
    enum AccountStatus {
        case unavailable
        case authorized(AccessToken)
    }
    
    enum Errors: Error {
        case unableToGetToken, invalidResponse
    }
    
    // MARK: - Properties
    
    // MARK: - Getting the current twitter account
    
    func getTokenRequestSignalProducer() -> SignalProducer<String, NetworkError> {
        guard let request = TwitterAPI.createRequest(URL(string: "https://api.twitter.com/oauth2/token"),
                                                     parameters: ["grant_type": "client_credentials"],
                                                     headers: ["Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"],
                                                     method: .post) else {
                                                        return SignalProducer<String, NetworkError> { observer, _ in
                                                            observer.send(error: NetworkError.invalidUrl)
                                                        }
        }
        return TwitterAPI.performRequest(by: request)
    }
    
    var account: SignalProducer<AccountStatus, NoError> {
        return getTokenRequestSignalProducer()
            .flatMapError { _ in
                return SignalProducer<String, NoError>(value: "")
            }
            .map { token in
                token.isEmpty ? AccountStatus.unavailable : AccountStatus.authorized(token)
            }
    }
}
