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

class TwitterAccount {
    
    /// Singleton
    static let shared = TwitterAccount()
    
    /**
     Authorization status
     
     - unavailable: not authorized
     - authorized: authorized with token
    */
    enum AccountStatus {
        case unavailable
        case authorized(AccessToken)
    }
    
    // MARK: - Constants
    
    fileprivate static let tokenPersistanceKey = "ReactiveTwitter token"
    
    // MARK: - Properties
    
    private var key: String!
    
    private var secret: String!
    
    /// Setter for key and secret
    public func set(key: String, secret: String) {
        self.key = key
        self.secret = secret
    }
    
    /// User token
    var token: String? {
        get {
            return KeyChain.retrieveValue(for: TwitterAccount.tokenPersistanceKey)
        }
        set {
            KeyChain.store(newValue, key: TwitterAccount.tokenPersistanceKey)
        }
    }
    
    /// Account
    var account: SignalProducer<AccountStatus, NoError> {
        return SignalProducer<AccountStatus, NoError> { observer, _ in
            if let token = self.token {
                observer.send(value: AccountStatus.authorized(token))
                observer.sendCompleted()
            } else {
                self.getTokenRequestSignalProducer()
                    .flatMapError { _ in
                        return SignalProducer<Token, NoError>(value: Token(token: "", tokenType: ""))
                    }
                    .map { token -> TwitterAccount.AccountStatus in
                        guard !token.token.isEmpty else {
                            return AccountStatus.unavailable
                        }
                        self.token = token.token
                        return AccountStatus.authorized(token.token)
                    }
                    .startWithValues { value in
                        observer.send(value: value)
                        observer.sendCompleted()
                    }
                
            }
            }.replayLazily(upTo: 1)
    }
    
    // MARK: - Functions
    
    /**
     Returns SignalProducer that emits user token
     
     - Returns: SignalProducer emitting token
     */
    func getTokenRequestSignalProducer() -> SignalProducer<Token, NetworkError> {
        var headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded;charset=UTF-8", "Accept-Encoding":"gzip", "Host": "api.twitter.com"]
        if let authorizationHeader = authorizationHeader(user: TwitterAccount.shared.key, password: TwitterAccount.shared.secret) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        guard let request = TwitterAPI.createRequest(URL(string: "https://api.twitter.com/oauth2/token"),
                                                     bodyParameters: "grant_type=client_credentials",
                                                     headers: headers,
                                                     method: .post) else {
                                                        return SignalProducer<Token, NetworkError> { observer, _ in
                                                            observer.send(error: NetworkError.invalidUrl)
                                                        }
        }
        let dataSignalProducer: SignalProducer<Data, NetworkError> = TwitterAPI.performRequest(by: request)
        return dataSignalProducer.map { data in
            try? JSONDecoder().decode(Token.self, from: data)
        }
        .skipNil()
    }
    
    /**
     Returns Authorization header with encoded credentials
     
     - Parameter user: login
     
     - Parameter password: password
     
     - Returns: Authorization key-value pair
     */
    fileprivate func authorizationHeader(user: String, password: String) -> (key: String, value: String)? {
        guard let data = "\(user):\(password)".data(using: .utf8) else { return nil }
        
        let credential = data.base64EncodedString(options: [])
        
        return (key: "Authorization", value: "Basic \(credential)")
    }
}
