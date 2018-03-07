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
    
    var tweetsProducer: SignalProducer<[Tweet], NoError>!
    
    var account: SignalProducer<Bool, NoError>!
    
    init(localDatamanager: TweetListLocalDataManagerProtocol,
         remoteDatamanager: TweetListRemoteDataManagerProtocol,
         account: SignalProducer<Bool, NoError>) {
//        account = TwitterAccount().account.map { status in
//            switch status {
//            case .unavailable: return false
//            case .authorized: return true
//            }
//        }
        self.account = account
        self.localDatamanager = localDatamanager
        self.remoteDatamanager = remoteDatamanager
        
        tweetsProducer = localDatamanager.tweetsProducer
        remoteDatamanager.tweetsProducer.startWithValues { changes in
            localDatamanager.updateChanges(changes)
        }
        // Subscribe to remoteDatamanager and update localDatamanager on every new data
        
    }
}
