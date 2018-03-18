//
//  TweetListRemoteDataManager.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

class TweetListRemoteDataManager: TweetListRemoteDataManagerProtocol {
    
    // MARK: - Properties
    
    /// SignalProducer emitting current authorization status
    fileprivate var account: SignalProducer<TwitterAccount.AccountStatus, NoError>!
    
    // MARK: - Initializer
    
    init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) {
        self.account = account
    }
    
    // MARK: - Functions
    
    /**
     Creates DataProvider returning tweets by performing request to remote server
     
     - Parameter jsonProvider: function that accepts current token, performs request and
     returns SignalProducer emitting response Data
     
     - Returns SignalProducer emitting tweets converted from data
     */
    func createDataProvider(jsonProvider: @escaping (AccessToken) -> SignalProducer<Data, NetworkError>) -> SignalProducer<[Tweet], NoError> {

        let currentAccount: SignalProducer<AccessToken, NoError> = account
            .filter { account in
                switch account {
                case .authorized: return true
                default: return false
                }
            }
            .map { account -> AccessToken in
                switch account {
                case .authorized(let acaccount):
                    return acaccount
                default: fatalError()
                }
            }
        // timer that emits a reachable logged account
        let reachableAccount: SignalProducer<AccessToken?, NoError> = SignalProducer.combineLatest(
            Reachability.isConnected(),
            currentAccount)
            .map { reachable, account in
                return reachable ? account : nil
            }
        
        // Refetch the feed
        let tweetsProducer: SignalProducer<[Tweet]?, NetworkError> = reachableAccount
            .skipNil()
            .flatMap(.latest, jsonProvider)
            .observe(on: QueueScheduler.main)
            .map { data -> [Tweet]? in
                let context = CoreDataStore.persistentContainer?.newBackgroundContext()
                let decoder = JSONDecoder()
                decoder.userInfo[.context] = context
                guard let result = try? decoder.decode(SearchResponse.self, from: data) else {
                    print(String(data: data, encoding: .utf8) ?? "Empty data")
                    return nil
                }
                return result.statuses
            }
        
        return tweetsProducer
            .skipNil()
            .flatMapError({ (_) -> SignalProducer<[Tweet], NoError> in
                SignalProducer.empty
            })
    }
}
