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
    private let feedCursor = MutableProperty<TweetListCursor>(.none)
    
    private let hashtagQuery = MutableProperty<String>("")
    
    // MARK: output
    var getTweetsAction: Action<Query, [Tweet], NoError>!
    
    init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) {
        getTweetsAction = Action<Query, [Tweet], NoError> { value in
            return self.createDataProvider(account: account, jsonProvider: TwitterAPI.getTweetList(for: value))
        }
    }
    
    
    private func createDataProvider(account: SignalProducer<TwitterAccount.AccountStatus, NoError>,
         jsonProvider: @escaping (AccessToken) -> SignalProducer<Data, NetworkError>) -> SignalProducer<[Tweet], NoError> {

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
        
        
        // Re-fetch the feed
        let tweetsProducer: SignalProducer<[Tweet]?, NetworkError> = reachableAccount
            .skipNil()
            .flatMap(.latest, jsonProvider)
            .observe(on: QueueScheduler.main)
            .map { data -> [Tweet]? in
                let context = CoreDataStore.managedObjectContext
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
