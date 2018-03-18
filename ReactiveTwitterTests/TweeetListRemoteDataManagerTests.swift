//
//  TweeetListRemoteDataManagerTests.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 08.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import XCTest
import ReactiveSwift
import Result

@testable import ReactiveTwitter

class TweetListRemoteDataManagerTests: XCTestCase {
    
    let authorizedAccount = SignalProducer<TwitterAccount.AccountStatus, NoError> { observer, _ in
        observer.send(value: TwitterAccount.AccountStatus.authorized(AccessToken()))
        observer.sendCompleted()
    }
    
    let unauthorizedAccount = SignalProducer<TwitterAccount.AccountStatus, NoError> { observer, _ in
        observer.send(value: TwitterAccount.AccountStatus.unavailable)
        observer.sendCompleted()
    }
    
    let query: Query = ((nil, nil, 10), "Test")
    
    fileprivate func createDataProvider(account: SignalProducer<TwitterAccount.AccountStatus, NoError>) -> SignalProducer<[Tweet], NoError> {
        let remoteDataManager = TweetListRemoteDataManager(account: account)
        return remoteDataManager.createDataProvider(jsonProvider: TwitterAPI.getTweetList(for: query))
    }
    
    fileprivate func createUnauthorizedDataProvider() -> SignalProducer<[Tweet], NoError> {
        return createDataProvider(account: unauthorizedAccount)
    }
    
    fileprivate func createAuthorizedDataProvider() -> SignalProducer<[Tweet], NoError> {
        return createDataProvider(account: authorizedAccount)
    }
 
    func test_sending_tweets_on_start() {
        createAuthorizedDataProvider().startWithValues { [weak self] value in
            self?.AssertMultipleTweetsEqual(value, TweetsData.tweets)
        }
    }
    
    func test_not_sending_tweets_on_anauthorized_account() {
        let resultObserver = Signal<[Tweet], NoError>.Observer(
            value: { _ in XCTFail() },
            interrupted: { XCTAssertTrue(true)}
        )
        createUnauthorizedDataProvider().start(resultObserver)
    }
    
    func test_changing_authorization_status() {
        var isAuthorized = true
        let changingStatusAccount = SignalProducer<TwitterAccount.AccountStatus, NoError> { observer, _ in
            isAuthorized = !isAuthorized
            observer.send(value: isAuthorized ? TwitterAccount.AccountStatus.authorized(AccessToken()) : TwitterAccount.AccountStatus.unavailable)
            observer.sendCompleted()
        }
        let dataProvider = createDataProvider(account: changingStatusAccount)
        let resultObserver = Signal<[Tweet], NoError>.Observer(
            value: { _ in XCTFail() },
            interrupted: { XCTAssertTrue(true)}
        )
        dataProvider.start(resultObserver)
        dataProvider.startWithValues { [weak self] value in
            self?.AssertMultipleTweetsEqual(value, TweetsData.tweets)
        }
    }
}
