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
    
    private let timerDelay = 30
    private let feedCursor = MutableProperty<TweetListCursor>(.none)
    
    // MARK: input
    let paused = MutableProperty<Bool>(false)
    
    // MARK: output
    var tweetsProducer: SignalProducer<[Tweet], NoError>!
    
    convenience init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>,
                     hashtag: String,
                     apiType: TwitterAPIProtcol.Type) {
        self.init(account: account, jsonProvider: apiType.getTweetList(for: hashtag))
    }
    
    private init(account: SignalProducer<TwitterAccount.AccountStatus, NoError>,
         jsonProvider: @escaping (AccessToken, TweetListCursor) -> SignalProducer<Data, NetworkError>) {
        //
        // subscribe for the current twitter account
        //
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
            SignalProducer.timer(interval: DispatchTimeInterval.seconds(timerDelay), on: QueueScheduler.main),
            Reachability.isConnected(),
            currentAccount,
            paused.producer)
            .map {_, reachable, account, paused in
            return (reachable && !paused) ? account : nil
            }
            .filter { $0 != nil }
            .map { $0! }
        
        // Re-fetch the feed
        tweetsProducer = reachableTimerWithAccount
            .withLatest(from: feedCursor.producer)
            .flatMap(.latest) { token, cursor in
                jsonProvider(token, cursor)
            }
            .flatMapError  { _ in SignalProducer.empty }
            .map { value in
                try! JSONDecoder().decode([Tweet].self, from: value)
            }
        feedCursor <~ tweetsProducer
            .scan(.none, TweetListRemoteDataManager.currentCursor)
        
    }
    
    static func currentCursor(lastCursor: TweetListCursor, tweets: [Tweet]) -> TweetListCursor {
        return tweets.reduce(lastCursor) { status, tweet in
            let max: Int64 = tweet.id < status.maxId ? tweet.id-1 : status.maxId
            let since: Int64 = tweet.id > status.sinceId ? tweet.id : status.sinceId
            return TweetListCursor(max: max, since: since)
        }
    }
}
