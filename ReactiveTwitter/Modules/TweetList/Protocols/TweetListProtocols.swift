//
//  TweetListProtocols.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import ReactiveSwift

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
    var view: TweetListViewProtocol? { get set }
    var interactor: TweetListInteractorInputProtocol? { get set }
    var wireFrame: TweetListWireFrameProtocol? { get set }
    
    var tweets: Property<[Tweet]> { get set }
    var loggedIn: Property<Bool> { get set }
    
    func getTweet(at index: Int) -> Tweet
    func getTweetsCount() -> Int
}

protocol TweetListInteractorOutputProtocol: class {
    // INTERACTOR -> PRESENTER
    func didRetrieveTweets(_ Tweets: [Tweet])
    func onError()
}

protocol TweetListInteractorInputProtocol: class {
    var presenter: TweetListInteractorOutputProtocol? { get set }
    var localDatamanager: TweetListLocalDataManagerInputProtocol? { get set }
    var remoteDatamanager: TweetListRemoteDataManagerInputProtocol? { get set }
    
    // PRESENTER -> INTERACTOR
    func retrieveTweetList()
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
