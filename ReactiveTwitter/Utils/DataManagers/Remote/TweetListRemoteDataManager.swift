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
    
    // MARK: input
    let paused = MutableProperty<Bool>(false)
    
    // MARK: output
    var getTweetsAction: Action<Query, [Tweet], NoError>!
    
    init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) {
        getTweetsAction = Action<Query, [Tweet], NoError> { value in
            return self.createDataProvider(account: account, jsonProvider: TwitterAPI.getTweetList(for: value))
        }
    }
    
    
    // TODO: Change to action
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
        let reachableTimerWithAccount = SignalProducer.combineLatest(
            Reachability.isConnected(),
            currentAccount,
            paused.producer)
            .map { reachable, account, paused in
            return (reachable && !paused) ? account : nil
            }
            .filter { $0 != nil }
            .map { $0! }
        
        // Re-fetch the feed
        let tweetsProducer = reachableTimerWithAccount
            .flatMap(.latest) { token in
                jsonProvider(token)
            }
            .flatMapError  { _ in SignalProducer<Data, NoError>.empty }
            .map { value in
                try! JSONDecoder().decode([Tweet].self, from: value)
        }
        
        return tweetsProducer
    }
}
