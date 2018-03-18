//
//  MockInteractor.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 17.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import  Result
import ReactiveSwift
@testable import ReactiveTwitter

class MockTweetListInteractor: TweetListInteractorProtocol {
    // Properties
    var localDatamanager: TweetListLocalDataManagerProtocol!
    var remoteDatamanager: TweetListRemoteDataManagerProtocol!
    var account: SignalProducer<Bool, NoError>!
    
    // Presenter -> Interactor
    var prefetchObserver: Signal<Query, NoError>.Observer!
    
    // Interactor -> Presenter
    var tweetsSignal: Signal<([Tweet], Query), NoError>!
    
    init(prefetchObserver: Signal<Query, NoError>.Observer = Signal<Query, NoError>.Observer(), tweetsSignal: Signal<([Tweet], Query), NoError> = Signal<([Tweet], Query), NoError>.empty) {
        self.prefetchObserver = prefetchObserver
        self.tweetsSignal = tweetsSignal
        self.account = SignalProducer<Bool, NoError> { observer, _ in
            observer.send(value: true)
            observer.sendCompleted()
        }
    }
}
