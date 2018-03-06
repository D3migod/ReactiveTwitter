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
    
    var localDatamanager: TweetListLocalDataManagerInputProtocol?
    
    var remoteDatamanager: TweetListRemoteDataManagerInputProtocol?
    
    var paused: MutableProperty<Bool>!
    
    var tweetsProducer: SignalProducer<[Tweet], NoError>!
    
    var account: Signal<Bool, NoError>!
    
    init() {
        account = 
    }
}
