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

// MARK: - Typealias

typealias MinTweetId = Int64?

typealias MaxTweetId = Int64?

typealias TweetsCount = Int

typealias SearchString = String

typealias PrefetchCellIndices = [Int]

typealias Query = ((MinTweetId, MaxTweetId, TweetsCount), SearchString)

protocol TweetListViewProtocol: class {
    // Properties
    var presenter: TweetListPresenterProtocol! { get set }
}

protocol TweetListWireFrameProtocol: class {
    // Initializer
    static func createConnections(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) -> UIViewController
}

protocol TweetListPresenterProtocol: class {
    // Properties
    var interactor: TweetListInteractorProtocol! { get set }
    var wireFrame: TweetListWireFrameProtocol! { get set }
    
    // Presenter -> View
    var tweets: MutableProperty<[Tweet]>! { get }
    
    // View -> Presenter
    var prefetchObserver: Signal<([Int], String?), NoError>.Observer! { get }
    
    // Interactor -> Presenter
    var loggedIn: MutableProperty<Bool>! { get }
}

protocol TweetListInteractorProtocol: class {
    // Properties
    var localDatamanager: TweetListLocalDataManagerProtocol! { get set }
    var remoteDatamanager: TweetListRemoteDataManagerProtocol! { get set }
    var account: SignalProducer<Bool, NoError>! { get set }
    
    // Presenter -> Interactor
    var prefetchObserver: Signal<Query, NoError>.Observer! { get }
    
    // Interactor -> Presenter
    var tweetsSignal: Signal<([Tweet], Query), NoError>! { get }
}

protocol TweetListRemoteDataManagerProtocol: class {
    // RemoteDataManager -> Interactor
    func createDataProvider(jsonProvider: @escaping (AccessToken) -> SignalProducer<Data, NetworkError>) -> SignalProducer<[Tweet], NoError>
}


protocol TweetListLocalDataManagerProtocol: class {
    // Interactor -> LocalDataManager
    func save(_ tweets: [Tweet])
    
    // LocalDataManager -> Interactor
    func getTweets(for query: Query) throws -> [Tweet]
}
