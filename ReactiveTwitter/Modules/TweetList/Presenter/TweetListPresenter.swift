//
//  TweetListPresenter.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

typealias Query = ((Int64?, Int64?, Int), String) // TODO: Change to typealias

class TweetListPresenter: TweetListPresenterProtocol {
    
    fileprivate static let defaultPageSize = 10
    
    var prefetchObserver: Signal<([Int], String?), NoError>.Observer!
    var prefetchSignalFromView: Signal<([Int], String?), NoError>!
    
    var prefetchSignal: Signal<Query, NoError>!
    
    var interactor: TweetListInteractorProtocol!
    
    var wireFrame: TweetListWireFrameProtocol!
    
    // MARK: - Input
    var paused: Bool = false {
        didSet {
            interactor.paused.value = paused
        }
    }
    
    // MARK: - Output
    var tweets: MutableProperty<[Tweet]>! //private(set)
    
    var loggedIn: MutableProperty<Bool>!
    
    var maxId: MutableProperty<Int64>!
    
    var minId: MutableProperty<Int64>!
    
    init(interactor: TweetListInteractorProtocol,
         wireFrame: TweetListWireFrameProtocol) {
        self.interactor = interactor
        self.wireFrame = wireFrame
        
        loggedIn = MutableProperty<Bool>(false)
        maxId = MutableProperty<Int64>(0)
        minId = MutableProperty<Int64>(0)
        tweets = MutableProperty<[Tweet]>([])
        // Subscribe to interactor changes of account visibility
        loggedIn <~ interactor.account
        
        maxId <~ interactor.tweetsSignal
            .combineLatest(with: maxId.signal)
            .map { newTweets, currentMax -> (Int64?) in
                guard let receivedMax = newTweets.map({$0.id}).max() else { return nil }
                return receivedMax > currentMax ? receivedMax : nil
            }
            .skipNil()
        
        minId <~ interactor.tweetsSignal
            .combineLatest(with: maxId.signal)
            .map { newTweets, currentMin -> (Int64?) in
                guard let receivedMin = newTweets.map({$0.id}).min() else { return nil }
                return receivedMin < currentMin ? receivedMin : nil
            }
            .skipNil()
        
        let (prefetchSignalFromView, prefetchObserver) = Signal<([Int], String?), NoError>.pipe()
        self.prefetchSignalFromView = prefetchSignalFromView
        self.prefetchSignal = Signal.combineLatest(
            self.prefetchSignalFromView.logEvents(),
            tweets.signal.logEvents(),
            minId.signal.logEvents())
            .map { (prefetchQuery, tweets, minId) -> Query? in
                let (indices, hashtag) = prefetchQuery
                guard let unwrappedHashtag = hashtag else { return nil }
                if indices.isEmpty {
                    return ((nil, nil, TweetListPresenter.defaultPageSize), unwrappedHashtag)
                } else {
                    guard let maxIndex = indices.max() else { return nil}
                    if maxIndex + 1 > tweets.count {
                        return ((nil, minId-1, TweetListPresenter.defaultPageSize), unwrappedHashtag)
                    }
                    return nil
                }
            }
            .skipNil()
        
        // Subscribe to interactor changes of tweets (in local database)
        tweets <~ SignalProducer.combineLatest(
            interactor.tweetsSignal,
            tweets.producer,
            SignalProducer(prefetchSignal))
            .map { newTweets, currentTweets, lastQuery in
                let indices = lastQuery.1
                return indices.count == 0 ? newTweets : currentTweets + newTweets // TODO: Handle tweet update
        }
        
        minId.value = 0
        tweets.value = []
        
        self.prefetchObserver = prefetchObserver
        
        self.prefetchSignal.observe(interactor.prefetchObserver)
    }
    
    
}
