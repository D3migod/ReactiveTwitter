//
//  TweetListLocalDataManagerTests.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 17.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import XCTest
import CoreData
@testable import ReactiveTwitter

class TweetListLocalDataManagerTests: XCTestCase {
    
    var dataManager: TweetListLocalDataManagerProtocol!
    
    var saveNotificationCompleteHandler: ((Notification)->())?
    
    override func setUp() {
        super.setUp()
        dataManager = TweetListLocalDataManager(coreDataLimit: 3)
        try? dataManager.clear()
        NotificationCenter.default.addObserver(self, selector: #selector(contextSaved(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave , object: nil)
    }
    
    override func tearDown() {
        super.tearDown()
        NotificationCenter.default.removeObserver(self)
        do {
            try dataManager.clear()
        } catch {
            print("Cannot clear the database")
        }
    }
    
    fileprivate func AssertFetchedTweetsEqual(_ secondTweets: [Tweet], skipFirst: Bool = false,
                                                    file: StaticString = #file, line: UInt = #line) {
        var mutableSkipFirst = skipFirst
        let expect = expectation(description: "Context Saved")
        waitForSavedNotification { [weak self] (notification) in
            if mutableSkipFirst {
                mutableSkipFirst = false
                return
            }
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                let context = notification.object as? NSManagedObjectContext
                let fetchRequest: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
                guard let result = try? context?.fetch(fetchRequest), let receivedTweets = result else { XCTFail(); return }
                print(receivedTweets)
                strongSelf.AssertMultipleTweetsEqual(receivedTweets, secondTweets, file: file, line: line)
                expect.fulfill()
            }
        }
    }
    
    fileprivate func getTweets() -> [Tweet] {
        guard let tweets = try? dataManager.getTweets(for: ((0, 10, 10), "Test")) else {
            XCTFail()
            return []
        }
        return tweets
    }
    
    func test_save() {
        AssertFetchedTweetsEqual(TweetsData.tweets)
        dataManager.save(TweetsData.tweets)
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_get() {
        let expect = expectation(description: "Context Saved")
        waitForSavedNotification { [weak self] (notification) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.AssertMultipleTweetsEqual(strongSelf.getTweets(), [TweetsData.tweets.first!])
                expect.fulfill()
            }
        }
        dataManager.save(TweetsData.tweets)
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_save_same_instance() {
        AssertFetchedTweetsEqual(TweetsData.tweets, skipFirst: true)
        dataManager.save(TweetsData.tweets)
        dataManager.save(TweetsData.tweets)
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_save_renew() {
        var tweets = TweetsData.tweets
        let tweet = TweetsData.tweet
        tweet.id = tweets.first?.id ?? -1
        tweets[0] = tweet
        AssertFetchedTweetsEqual(tweets, skipFirst: true)
        dataManager.save(tweets)
        dataManager.save([tweet])
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_preserve_limits() {
        try! dataManager.clear()
        var resultesTweets = TweetsData.tweets
        resultesTweets.removeFirst()
        resultesTweets.append(TweetsData.tweet)
        AssertFetchedTweetsEqual(resultesTweets.sorted(by: { $0.id < $1.id }), skipFirst: true)
        dataManager.save(TweetsData.tweets)
        dataManager.save([TweetsData.tweet])
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func test_delete_once_per_load_preserved() {
        dataManager = TweetListLocalDataManager(coreDataLimit: 3, deleteOnceOverload: 0.5)
        AssertFetchedTweetsEqual([TweetsData.tweets.last!, TweetsData.tweet].sorted(by: { $0.id < $1.id }), skipFirst: true)
        dataManager.save(TweetsData.tweets)
        dataManager.save([TweetsData.tweet])
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    func expectationForSaveNotification() -> XCTestExpectation {
        let expect = expectation(description: "Context Saved")
        waitForSavedNotification { (notification) in
            expect.fulfill()
        }
        return expect
    }
    
    func waitForSavedNotification(completeHandler: @escaping ((Notification)->()) ) {
        saveNotificationCompleteHandler = completeHandler
    }
    
    func contextSaved( notification: Notification ) {
        saveNotificationCompleteHandler?(notification)
    }
}
