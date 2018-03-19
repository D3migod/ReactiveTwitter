//
//  XCTest+compareTweets.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 17.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import XCTest
@testable import ReactiveTwitter

extension XCTestCase {
    
    // Creating custom assertion because Tweet's equality function compares id values only.
    func AssertSingleTweetsEqual(
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
        XCTAssertEqual(firstTweet.hashtags?.map{$0.text} ?? [], secondTweet.hashtags?.map{$0.text} ?? [], "hashtags",
                       file: file, line: line) // ignore tweets field because it's not set if object is not saved in coreData
    }
    
    func AssertMultipleTweetsEqual(
        _ firstTweets: [Tweet], _ secondTweets: [Tweet],
        file: StaticString = #file, line: UInt = #line
        ) {
        guard firstTweets.count == secondTweets.count else {
            XCTFail()
            return
        }
        Array(zip(firstTweets, secondTweets)).forEach{AssertSingleTweetsEqual($0.0, $0.1, file: file, line: line)}
    }
}
