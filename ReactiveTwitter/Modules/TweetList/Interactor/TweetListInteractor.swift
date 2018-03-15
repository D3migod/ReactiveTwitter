//
//  TweetListInteractor.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class TweetListInteractor: TweetListInteractorProtocol {
    var prefetchObserver: Signal<Query, NoError>.Observer!
    
    var localDatamanager: TweetListLocalDataManagerProtocol!
    
    var remoteDatamanager: TweetListRemoteDataManagerProtocol!
    
    var tweetsSignal: Signal<([Tweet], Query), NoError>!
    
    var account: SignalProducer<Bool, NoError>!
    
    init(localDatamanager: TweetListLocalDataManagerProtocol,
         remoteDatamanager: TweetListRemoteDataManagerProtocol,
         account: SignalProducer<TwitterAccount.AccountStatus, NoError>) {
        self.account = account.map { status in
            switch status {
            case .unavailable: return false
            case .authorized: return true
            }
        }
        self.localDatamanager = localDatamanager
        self.remoteDatamanager = remoteDatamanager
        
        let (prefetchSignal, prefetchObserver) = Signal<Query, NoError>.pipe()
        self.prefetchObserver = prefetchObserver
        self.tweetsSignal = prefetchSignal
            .flatMap(FlattenStrategy.latest) { query -> SignalProducer<([Tweet], Query), NoError> in
                guard !query.1.isEmpty else {
                    return SignalProducer(value: ([], query))
                }
                return Reachability.isConnected().flatMap(FlattenStrategy.latest) { isConnected -> SignalProducer<([Tweet], Query), NoError> in
                    if isConnected {
                        return remoteDatamanager.createDataProvider(jsonProvider: TwitterAPI.getTweetList(for: query))
                            .on(value: { tweets in
                                localDatamanager.save(tweets)
                            })
                            .map { tweets in
                                return (tweets, query)
                        }
                    } else {
                        guard let tweets = try? localDatamanager.getTweets(for: query) else {
                            print("Error occured")
                            return SignalProducer.empty
                        }
                        return SignalProducer(value: (tweets, query))
                    }
                }
        }
    }
}
