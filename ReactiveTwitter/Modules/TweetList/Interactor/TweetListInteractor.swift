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
    
    var tweetsSignal: Signal<[Tweet], PersistanceError>!
    
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
                remoteDatamanager.getTweetsAction.apply(query)
                    .startWithValues { tweets in
                        localDatamanager.save(tweets)
                        tweetsObserver.send(value: tweets)
                }
                
                tweetsObserver.send(value: )
                
            // If postIndices.isEmpty:
                // Retrieve first postIndices.count most fresh posts for the query from localDatamaner
                // Ask for remoteDataManager for new Posts if postIndices is 0
            // else:
                // if localDatamanager has postIndices.count posts older than currently shown
                    // do nothing
                // else:
                    // ask for remoteDatamanager to load postIndices.count posts older than the oldest ones
                    // Save loaded posts
        })
    }
}
