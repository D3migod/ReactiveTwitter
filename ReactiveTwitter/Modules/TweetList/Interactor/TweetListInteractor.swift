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
    
    var localDatamanager: TweetListLocalDataManagerProtocol!
    
    var remoteDatamanager: TweetListRemoteDataManagerProtocol!
    
    var paused: MutableProperty<Bool>!
    
    var tweetsProducer: SignalProducer<[Tweet], NoError>! {
        get {
            return remoteDatamanager.tweetsProducer
        }
    }
    
    var account: SignalProducer<Bool, NoError>!
    
    init(localDatamanager: TweetListLocalDataManagerProtocol,
         remoteDatamanager: TweetListRemoteDataManagerProtocol,
         account: SignalProducer<Bool, NoError>) {
        self.account = account
        self.localDatamanager = localDatamanager
        self.remoteDatamanager = remoteDatamanager
        remoteDatamanager.tweetsProducer.
    }
}
