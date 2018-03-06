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
    var localDatamanager: TweetListLocalDataManagerInputProtocol? { get set }
    var remoteDatamanager: TweetListRemoteDataManagerInputProtocol? { get set }
    
    // PRESENTER -> INTERACTOR
    var paused: MutableProperty<Bool>! { get set }
    
    // INTERACTOR -> Presenter
    var tweetsProducer: SignalProducer<[Tweet], NoError>! { get set }
    var account: Signal<Bool, NoError>! { get set }
}

protocol TweetListDataManagerInputProtocol: class {
    // INTERACTOR -> DATAMANAGER
}

protocol TweetListRemoteDataManagerInputProtocol: class {
    var remoteRequestHandler: TweetListRemoteDataManagerOutputProtocol? { get set }
    
    // INTERACTOR -> REMOTEDATAMANAGER
    func retrieveTweetList()
}

protocol TweetListRemoteDataManagerOutputProtocol: class {
    // REMOTEDATAMANAGER -> INTERACTOR
    func onTweetsRetrieved(_ Tweets: [Tweet])
    func onError()
}

protocol TweetListLocalDataManagerInputProtocol: class {
    // INTERACTOR -> LOCALDATAMANAGER
    func retrieveTweetList() throws -> [Tweet]
    func saveTweet(id: Int, title: String, imageUrl: String, thumbImageUrl: String) throws
}
