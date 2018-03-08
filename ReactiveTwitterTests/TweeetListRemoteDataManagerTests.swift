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
    
    fileprivate func create(_ account: Signal<TwitterAccount.AccountStatus, NoError>) -> TweetListRemoteDataManager {
        
        let jsonProvider: (AccessToken, TweetListCursor) -> SignalProducer<Data, NoError> = { _, _ in
            return SignalProducer<Data, NoError>(value: TweetsData.tweetsJson)
        }
        return TweetListRemoteDataManager(
            account: account,
            jsonProvider: jsonProvider)
    }
    
    // Creating custom assertion because Tweet's equality function compares id values only.
    fileprivate func AssertSingleTweetsEqual(
        _ firstTweet: Tweet, _ secondTweet: Tweet,
        file: StaticString = #file, line: UInt = #line
        ) {
        XCTAssertEqual(firstTweet.id, secondTweet.id, "id",
                       file: file, line: line)
        XCTAssertEqual(firstTweet.text, secondTweet.text, "text",
                       file: file, line: line)
        XCTAssertEqual(firstTweet.name, secondTweet.name, "name",
                       file: file, line: line)
        XCTAssertEqual(firstTweet.created, secondTweet.created, "created",
                       file: file, line: line)
        XCTAssertEqual(firstTweet.imageUrl, secondTweet.imageUrl, "image url",
                       file: file, line: line)
    }
    
    fileprivate func AssertMultipleTweetsEqual(
        _ firstTweets: [Tweet], _ secondTweets: [Tweet],
        file: StaticString = #file, line: UInt = #line
        ) {
        Array(zip(firstTweets, secondTweets)).forEach{AssertSingleTweetsEqual($0.0, $0.1, file: file, line: line)}
    }
    
    func fields_are_filled_on_init() {
        
    }
 
    func test_sending_tweets_on_start() {
        let (account, observer) = Signal<TwitterAccount.AccountStatus, NoError>.pipe()
        let remoteDataManager = create(account)
        
        observer.send(value: .authorized(AccessToken()))
        remoteDataManager.tweetsProducer.startWithValues { [weak self] value in
            self?.AssertMultipleTweetsEqual(value, TweetsData.tweets)
        }
    }
    
    func test_not_sending_tweets_on_anauthorized_account() {
        let (account, observer) = Signal<TwitterAccount.AccountStatus, NoError>.pipe()
        let remoteDataManager = create(account)
        
        observer.send(value: .unavailable)
        let resultObserver = Signal<[Tweet], NoError>.Observer(
            value: { _ in XCTFail() },
            interrupted: { XCTAssertTrue(true)}
        )
        let disposable = remoteDataManager.tweetsProducer.start(resultObserver)
        disposable.dispose()
    }
    
    func test_start_sending_tweets_on_authorization() {
        let (account, observer) = Signal<TwitterAccount.AccountStatus, NoError>.pipe()
        let remoteDataManager = create(account)
        
        observer.send(value: .unavailable)
        remoteDataManager.tweetsProducer.startWithValues { [weak self] value in
            self?.AssertMultipleTweetsEqual(value, TweetsData.tweets)
        }
        observer.send(value: .authorized(AccessToken()))
    }
    
    func test_current_cursor_pointing_on_start() {
    
    }
    
    func test_current_cursor_pointing_on_middle_after_shift() {
        
    }
    
    func test_current_cursor_zero_tweets() {
        
    }
    
    func test_no_feed_on_paused() {
        
    }
}
