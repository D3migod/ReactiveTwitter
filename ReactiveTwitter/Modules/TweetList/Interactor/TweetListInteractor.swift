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
    
    var tweetsObserver: Signal<([Tweet], Query), NoError>.Observer!
    
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
        
        let (tweetsSignal, tweetsObserver) = Signal<([Tweet], Query), NoError>.pipe()
        self.tweetsSignal = tweetsSignal
        self.tweetsObserver = tweetsObserver
        self.prefetchObserver = Signal<Query, NoError>.Observer(
            value: { query in
                guard !query.1.isEmpty else {
                    tweetsObserver.send(value: ([], query))
                    return
                }
                Reachability.isConnected().startWithValues({ (isInternetAvailable) in
                    if isInternetAvailable {
                        remoteDatamanager.getTweetsAction.apply(query).startWithResult { (result) in
                            switch result {
                            case .success(let tweets):
                                localDatamanager.save(tweets)
                                tweetsObserver.send(value: (tweets, query))
                            case .failure(let error):
                                print("Remote server error occurred: \(error)")
                                switch error {
                                case .disabled:
                                    return
                                default:
                                    guard let tweets = try? localDatamanager.getTweets(for: query) else {
                                        print("Local database rrror occured")
                                        return
                                    }
                                    tweetsObserver.send(value: (tweets, query))
                                    return
                                }
                            }
                        }
                    } else {
                        guard let tweets = try? localDatamanager.getTweets(for: query) else {
                            print("Error occured")
                            return
                        }
                        tweetsObserver.send(value: (tweets, query))
                    }
                })
        })
    }
}
