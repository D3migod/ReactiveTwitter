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

class TweetListPresenter: TweetListPresenterProtocol {
    
    // MARK: - Constants
    
    fileprivate static let defaultPageSize = 20
    
    fileprivate static let defaultFetchThreshold = 10
    
    // MARK: - Properties
    
    var interactor: TweetListInteractorProtocol!
    
    var wireFrame: TweetListWireFrameProtocol!
    
    // MARK: - View -> Presenter
    
    var prefetchObserver: Signal<(PrefetchCellIndices, SearchString?), NoError>.Observer!
    
    // MARK: - Presenter -> Interactor
    
    var prefetchSignal: Signal<Query, NoError>!
    
    // MARK: - Presenter -> View
    
    var tweets: MutableProperty<[Tweet]>!
    
    var loggedIn: MutableProperty<Bool>!
    
    // MARK: - Initializer
    
    init(interactor: TweetListInteractorProtocol,
         wireFrame: TweetListWireFrameProtocol,
         pageSize: Int = defaultPageSize,
         fetchThreshold: Int = defaultFetchThreshold) {
        self.interactor = interactor
        self.wireFrame = wireFrame
        
        loggedIn = MutableProperty<Bool>(false)
        tweets = MutableProperty<[Tweet]>([])
        loggedIn <~ interactor.account
        
        let (prefetchSignalFromView, prefetchObserver) = Signal<([Int], String?), NoError>.pipe()
        let filteredPrefetchSignal = prefetchSignalFromView
            .throttle(0.5, on: QueueScheduler.main)
            .skipRepeats({ (firstValue, secondValue) -> Bool in
                return firstValue.0 == secondValue.0 && firstValue.1 == secondValue.1
            })
            .filter { [weak self] prefetchQuery in
                guard let strongSelf = self else { return false }
                guard let maxIndex = prefetchQuery.0.max() else { return true }
                return strongSelf.tweets.value.count - (maxIndex + 1) < fetchThreshold
            }
        self.prefetchSignal = filteredPrefetchSignal
            .map { [weak self] (prefetchQuery) -> Query? in
                guard let strongSelf = self else { return nil }
                let (indices, hashtag) = prefetchQuery
                guard let unwrappedHashtag = hashtag else { return nil }
                if indices.isEmpty {
                    return ((nil, nil, pageSize), unwrappedHashtag)
                } else if let minId = strongSelf.tweets.value.last?.id {
                    return ((nil, minId-1, pageSize), unwrappedHashtag)
                } else {
                    return nil
                }
            }
            .skipNil()
        
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
