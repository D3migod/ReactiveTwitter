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
    
    fileprivate static let defaultPageSize = 20
    
    fileprivate static let fetchThreshold = 10
    
    var prefetchObserver: Signal<([Int], String?), NoError>.Observer!
    
    var prefetchSignalFromView: Signal<([Int], String?), NoError>!
    
    var prefetchSignal: Signal<Query, NoError>!
    
    var interactor: TweetListInteractorProtocol!
    
    var wireFrame: TweetListWireFrameProtocol!
    
    // MARK: - Output
    var tweets: MutableProperty<[Tweet]>! //private(set)
    
    var loggedIn: MutableProperty<Bool>!
    
    init(interactor: TweetListInteractorProtocol,
         wireFrame: TweetListWireFrameProtocol) {
        self.interactor = interactor
        self.wireFrame = wireFrame
        
        loggedIn = MutableProperty<Bool>(false)
        tweets = MutableProperty<[Tweet]>([])
        // Subscribe to interactor changes of account visibility
        loggedIn <~ interactor.account
        
        let (prefetchSignalFromView, prefetchObserver) = Signal<([Int], String?), NoError>.pipe()
        self.prefetchSignalFromView = prefetchSignalFromView
            .throttle(0.5, on: QueueScheduler.main)
            .skipRepeats({ (firstValue, secondValue) -> Bool in
                return firstValue.0 == secondValue.0 && firstValue.1 == secondValue.1
            })
            .filter { [weak self] prefetchQuery in
                guard let strongSelf = self else { return false }
                guard let maxIndex = prefetchQuery.0.max() else { return true }
                return strongSelf.tweets.value.count - (maxIndex + 1) < TweetListPresenter.fetchThreshold
            }
            .logEvents()
        self.prefetchSignal = self.prefetchSignalFromView
            .map { [weak self] (prefetchQuery) -> Query? in
                guard let strongSelf = self else { return nil }
                let (indices, hashtag) = prefetchQuery
                guard let unwrappedHashtag = hashtag else { return nil }
                if indices.isEmpty {
                    return ((nil, nil, TweetListPresenter.defaultPageSize), unwrappedHashtag)
                } else if let minId = strongSelf.tweets.value.last?.id {
                    return ((nil, minId-1, TweetListPresenter.defaultPageSize), unwrappedHashtag)
                } else {
                    return nil
                }
            }
            .skipNil()
        
        // Subscribe to interactor changes of tweets (in local database)
        tweets <~ interactor.tweetsSignal
            .map { [weak self] response -> [Tweet]? in
                guard let strongSelf = self else { return nil}
                let (newTweets, _) = response
                let currentTweets = strongSelf.tweets.value
                let sortedNewTweets = newTweets.sorted(by: { $0.id > $1.id })
                if currentTweets.isEmpty {
                    return sortedNewTweets
                } else if let currentMinId = strongSelf.tweets.value.last?.id, let receivedMaxId = sortedNewTweets.first?.id, currentMinId > receivedMaxId {
                    return currentTweets + sortedNewTweets
                } else {
                    return Array(Set(currentTweets + newTweets)).sorted(by: { $0.id > $1.id })
                }
            }
            .skipNil()
        
        tweets.value = []
        
        self.prefetchObserver = prefetchObserver
        
        self.prefetchSignal.observe(interactor.prefetchObserver)
    }
    
    
}
