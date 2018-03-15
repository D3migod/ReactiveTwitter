//
//  TweetListProtocols.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol TweetListViewProtocol: class {
    var presenter: TweetListPresenterProtocol! { get set }
}

protocol TweetListWireFrameProtocol: class {
    static func createConnections(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) -> UIViewController
}

protocol TweetListPresenterProtocol: class {
    var interactor: TweetListInteractorProtocol! { get set }
    var wireFrame: TweetListWireFrameProtocol! { get set }
    
    var tweets: MutableProperty<[Tweet]>! { get }
    var loggedIn: MutableProperty<Bool>! { get }
    var prefetchObserver: Signal<([Int], String?), NoError>.Observer! { get }
}

protocol TweetListInteractorProtocol: class {
    var localDatamanager: TweetListLocalDataManagerProtocol! { get set }
    var remoteDatamanager: TweetListRemoteDataManagerProtocol! { get set }
    
    // PRESENTER -> INTERACTOR
    var prefetchObserver: Signal<Query, NoError>.Observer! { get }
    
    // INTERACTOR -> Presenter
    var tweetsSignal: Signal<([Tweet], Query), NoError>! { get }
    var account: SignalProducer<Bool, NoError>! { get set }
}

protocol TweetListRemoteDataManagerProtocol: class {
    var getTweetsAction: Action<Query, [Tweet], NoError>! { get set }
}


protocol TweetListLocalDataManagerProtocol: class {
    func save(_ tweets: [Tweet])
    func getTweets(for query: Query) throws -> [Tweet]
}
