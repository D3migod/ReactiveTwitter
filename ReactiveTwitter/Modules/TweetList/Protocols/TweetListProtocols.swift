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
    var presenter: TweetListPresenterProtocol? { get set }
    
    // PRESENTER -> VIEW
    func showTweets(with Tweets: [Tweet])
    
    func showError()
    
    func showLoading()
    
    func hideLoading()
}

protocol TweetListWireFrameProtocol: class {
    static func createTweetListModule() -> UIViewController
    // PRESENTER -> WIREFRAME
    func presentTweetDetailScreen(from view: TweetListViewProtocol, forTweet Tweet: Tweet)
}

protocol TweetListPresenterProtocol: class {
    var view: TweetListViewProtocol! { get set }
    var interactor: TweetListInteractorProtocol! { get set }
    var wireFrame: TweetListWireFrameProtocol! { get set }
    
    var tweets: MutableProperty<[Tweet]>! { get }
    var loggedIn: MutableProperty<Bool>! { get }
}

protocol TweetListInteractorProtocol: class {
    var localDatamanager: TweetListLocalDataManagerProtocol! { get set }
    var remoteDatamanager: TweetListRemoteDataManagerProtocol! { get set }
    
    // PRESENTER -> INTERACTOR
    var paused: MutableProperty<Bool>! { get set }
    
    // INTERACTOR -> Presenter
    var tweetsProducer: SignalProducer<[Tweet], NoError>! { get set }
    var account: SignalProducer<Bool, NoError>! { get set }
}

protocol TweetListDataManagerInputProtocol: class {
    // INTERACTOR -> DATAMANAGER
}

protocol TweetListRemoteDataManagerProtocol: class {
    var tweetsProducer: SignalProducer<[Tweet], NetworkError> { get set }
}


protocol TweetListLocalDataManagerProtocol: class {
    var tweetsProducer: SignalProducer<[Tweet], NetworkError> { get set }
}
