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
    var getTweetsAction: Action<String, [Tweet], NoError>!
    
    init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) {
        getTweetsAction = Action<String, [Tweet], NoError> { value in
            return self.createDataProvider(account: account, jsonProvider: TwitterAPI.getTweetList(for: value))
        }
    }
    
    
    // TODO: Change to action
    private func createDataProvider(account: SignalProducer<TwitterAccount.AccountStatus, NoError>,
         jsonProvider: @escaping (AccessToken, TweetListCursor) -> SignalProducer<Data, NetworkError>) -> SignalProducer<[Tweet], NoError> {

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
            .withLatest(from: feedCursor.producer)
            .flatMap(.latest) { token, cursor in
                jsonProvider(token, cursor)
            }
            .flatMapError  { _ in SignalProducer<Data, NoError>.empty }
            .map { value in
                try! JSONDecoder().decode([Tweet].self, from: value)
        }
        
        // Increase feedCursor on every tweetsProducer .nextValue event
        feedCursor <~ tweetsProducer
            .scan(.none, TweetListRemoteDataManager.currentCursor)
        return tweetsProducer
    }
    
    static func currentCursor(lastCursor: TweetListCursor, tweets: [Tweet]) -> TweetListCursor {
        return tweets.reduce(lastCursor) { status, tweet in
            let max: Int64 = tweet.id < status.maxId ? tweet.id-1 : status.maxId
            let since: Int64 = tweet.id > status.sinceId ? tweet.id : status.sinceId
            return TweetListCursor(max: max, since: since)
        }
    }
}
