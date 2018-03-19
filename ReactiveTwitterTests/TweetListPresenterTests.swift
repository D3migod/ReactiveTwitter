//
//  TweetListPresenterTests.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 17.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result

@testable import ReactiveTwitter

class TweetListPresenterTests: XCTestCase {
    
    fileprivate static let defaultPageSize = 20
    
    fileprivate static let defaultFetchThreshold = 10
    
    fileprivate static let searchString = "Test"
    
    func createTweetListPresenter(interactor: TweetListInteractorProtocol = MockTweetListInteractor(),
                                  wireFrame: TweetListWireFrameProtocol = MockTweetListWireFrame(),
                                  pageSize: Int? = defaultPageSize,
                                  fetchThreshold: Int? = defaultFetchThreshold) -> TweetListPresenterProtocol {
        return TweetListPresenter(interactor: interactor, wireFrame: wireFrame)
    }
    
    func test_properties_are_initialized() {
        let presenter = createTweetListPresenter()
        XCTAssertTrue(presenter.interactor != nil)
        XCTAssertTrue(presenter.wireFrame != nil)
        XCTAssertTrue(presenter.loggedIn != nil)
        XCTAssertTrue(presenter.prefetchObserver != nil)
        XCTAssertTrue(presenter.tweets != nil)
    }
    
    func test_prefetch_signal_emits_right_queries() {
        let expect = expectation(description: "Value emitted")
        let interactorPrefetchObserver = Signal<Query, NoError>.Observer { value in
            switch value {
            case .value(let query):
                let correctValue: Query = ((nil, nil, TweetListPresenterTests.defaultPageSize), TweetListPresenterTests.searchString)
                XCTAssertEqual(query.0.0, correctValue.0.0)
                XCTAssertEqual(query.0.1, correctValue.0.1)
                XCTAssertEqual(query.0.2, correctValue.0.2)
                XCTAssertEqual(query.1, correctValue.1)
                expect.fulfill()
            default:
                break
            }
            
        }
        let presenter = createTweetListPresenter(interactor: MockTweetListInteractor(prefetchObserver: interactorPrefetchObserver))
        let (prefetchSignal, prefetchObserver) = Signal<([Int], String?), NoError>.pipe()
        prefetchSignal.observe(presenter.prefetchObserver)
        
        prefetchObserver.send(value: ([], TweetListPresenterTests.searchString))
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_prefetch_signal_emits_right_queries_when_tweets_non_empty() {
        let expect = expectation(description: "Value emitted")
        let interactorPrefetchObserver = Signal<Query, NoError>.Observer { value in
            switch value {
            case .value(let query):
                let correctValue: Query = ((nil, TweetsData.tweet.id-1, TweetListPresenterTests.defaultPageSize), TweetListPresenterTests.searchString)
                XCTAssertEqual(query.0.0, correctValue.0.0)
                XCTAssertEqual(query.0.1, correctValue.0.1)
                XCTAssertEqual(query.0.2, correctValue.0.2)
                XCTAssertEqual(query.1, correctValue.1)
                expect.fulfill()
            default:
                return
            }
        }
        let presenter = createTweetListPresenter(interactor: MockTweetListInteractor(prefetchObserver: interactorPrefetchObserver))
        presenter.tweets.value = [TweetsData.tweet]
        let (prefetchSignal, prefetchObserver) = Signal<([Int], String?), NoError>.pipe()
        prefetchSignal.observe(presenter.prefetchObserver)
        prefetchObserver.send(value: ([5], TweetListPresenterTests.searchString))
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_logged_in_status_is_not_logged() {
        let account = SignalProducer<Bool, NoError> { observer, _ in
            observer.send(value: false)
            observer.sendCompleted()
        }
        let interactor = MockTweetListInteractor(account: account)
        let presenter = createTweetListPresenter(interactor: interactor)
        XCTAssertTrue(!presenter.loggedIn.value)
    }
    
    func test_logged_in_status_is_logged() {
        let account = SignalProducer<Bool, NoError> { observer, _ in
            observer.send(value: true)
            observer.sendCompleted()
        }
        let interactor = MockTweetListInteractor(account: account)
        let presenter = createTweetListPresenter(interactor: interactor)
        XCTAssertTrue(presenter.loggedIn.value)
    }
    
    func test_tweets_saved() {
        let expect = expectation(description: "Value emitted")
        let (signal, observer) = Signal<([Tweet], Query), NoError>.pipe()
        let interactor = MockTweetListInteractor(tweetsSignal: signal)
        let presenter = createTweetListPresenter(interactor: interactor)
        presenter.tweets.signal.observe { [weak self] (event) in
            guard let strongSelf = self else { return }
            switch event {
            case .value(let value):
                strongSelf.AssertMultipleTweetsEqual(TweetsData.tweets.sorted(by: { $0.id > $1.id }), value)
                expect.fulfill()
            default:
                break
            }
        }
        observer.send(value: (TweetsData.tweets, ((nil, nil, 10), "")))
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
