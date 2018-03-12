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
    
    var paused: MutableProperty<Bool>!
    
    var tweetsSignal: Signal<[Tweet], NoError>!
    
    var tweetsObserver: Signal<[Tweet], NoError>.Observer!
    
    var account: SignalProducer<Bool, NoError>!
    
    init(localDatamanager: TweetListLocalDataManagerProtocol,
         remoteDatamanager: TweetListRemoteDataManagerProtocol,
         account: SignalProducer<Bool, NoError>) {
        self.account = account
        self.localDatamanager = localDatamanager
        self.remoteDatamanager = remoteDatamanager
        
        let (tweetsSignal, tweetsObserver) = Signal<[Tweet], NoError>.pipe()
        self.tweetsSignal = tweetsSignal
        self.tweetsObserver = tweetsObserver
        self.prefetchObserver = Signal<Query, NoError>.Observer(
            value: { query in
                remoteDatamanager.getTweetsAction.apply(query).startWithResult { (result) in
                    switch result {
                    case .success(let tweets):
                        localDatamanager.save(tweets)
                        tweetsObserver.send(value: tweets)
                    case .failure(let error):
                        print("Error occurred: \(error)")
                        break
                    }
                }
                
                guard let tweets = try? localDatamanager.getTweets(for: query) else {
                    print("Error occured")
                    return
                }
                guard tweets.count > 0 else {
                    print("No tweets count")
                    return
                }
                tweetsObserver.send(value: tweets)
        })
    }
}
