//
//  TweetsData.swift
//  ReactiveTwitterTests
//
//  Created by Bulat Galiev on 08.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
@testable import ReactiveTwitter

class TweetsData {
    static let tweetJson = """
    {
     "id": 4,
     "text": "Test4",
     "user": {
             "name": "Name4",
             "profile_image_url_https": "profile_url"
             },
     "created_at": "2011-11-11T20:00:00GMT",
     "entities": {
                 "hashtags": [
                             {
                             "text": "TestHashtag1",
                             "indices": [
                                    1,
                                    2
                             ]
                             }
                 ]
     }
    }
    """.data(using: .utf8)!
    
    static let tweetsJson = """
    [
    {
     "id": 1,
     "text": "Test1",
     "user": {
             "name": "Name1",
             "profile_image_url_https": "profile_url1"
             },
     "created_at": "2018-03-07T20:00:00GMT",
     "entities": {
                 "hashtags": [
                             {
                             "text": "TestHashtag2",
                             "indices": [
                                    3,
                                    4
                             ]
                             }
                 ]
     }
    },
    {
     "id": 2,
     "text": "Test2",
     "user": {
             "name": "Name2",
             "profile_image_url_https": "profile_url2"
             },
     "created_at": "2018-03-07T21:00:00GMT",
     "entities": {
                 "hashtags": []
     }
    },
    {
     "id": 3,
     "text": "Test3",
     "user": {
             "name": "Name3",
             "profile_image_url_https": "profile_url3"
             },
     "created_at": "2018-03-08T08:00:00GMT",
     "entities": {
                 "hashtags": []
     }
    }
    ]
    """.data(using: .utf8)!
    
    static var tweet: Tweet {
        let decoder = JSONDecoder()
        decoder.userInfo[.context] = CoreDataStore.managedObjectContext
        return try! decoder.decode(Tweet.self, from: tweetJson)
    }
    
    static var tweets: [Tweet]  {
        let decoder = JSONDecoder()
        decoder.userInfo[.context] = CoreDataStore.managedObjectContext
        return try! decoder.decode([Tweet].self, from: tweetsJson)
    }
}
