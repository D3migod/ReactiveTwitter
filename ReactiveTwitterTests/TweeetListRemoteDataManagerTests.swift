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
    
    let authorizedAccount = TwitterAccount.shared.account
    
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
        let expect = expectation(description: "Value emitted")
        createAuthorizedDataProvider().startWithValues { value in
            XCTAssertTrue(!value.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test_not_sending_tweets_on_anauthorized_account() {
        let expect = expectation(description: "Value emitted")
        let resultObserver = Signal<[Tweet], NoError>.Observer(
            value: { _ in XCTFail() },
            completed: { XCTAssertTrue(true); expect.fulfill() }
        )
        createUnauthorizedDataProvider().start(resultObserver)
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_changing_authorization_status() {
        let expect = expectation(description: "Value emitted")
        var isAuthorized = true
        let changingStatusAccount = SignalProducer<TwitterAccount.AccountStatus, NoError> { observer, _ in
            isAuthorized = !isAuthorized
            observer.send(value: isAuthorized ? TwitterAccount.AccountStatus.authorized(TwitterAccount.shared.token!) : TwitterAccount.AccountStatus.unavailable)
            observer.sendCompleted()
        }
        let dataProvider = createDataProvider(account: changingStatusAccount)
        let resultObserver = Signal<[Tweet], NoError>.Observer(
            value: { _ in XCTFail() },
            completed: { XCTAssertTrue(true)}
        )
        dataProvider.start(resultObserver)
        dataProvider.startWithValues { value in
            XCTAssertTrue(!value.isEmpty)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
