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
     "id": 1,
     "text": "Test",
     "user": [
             "name": "Name",
             "profile_image_url_https": "profile_url"
             ],
     "created": "2011-11-11T20:00:00GMT"
    }
    """.data(using: .utf8)!
    
    static let tweetsJson = """
    [
    {
     "id": 1,
     "text": "Test1",
     "user": [
             "name": "Name1",
             "profile_image_url_https": "profile_url1"
             ],
     "created": "2018-03-07T20:00:00GMT"
    },
    {
     "id": 2,
     "text": "Test2",
     "user": [
             "name": "Name2",
             "profile_image_url_https": "profile_url2"
             ],
     "created": "2018-03-07T21:00:00GMT"
    },
    {
     "id": 3,
     "text": "Test3",
     "user": [
             "name": "Name3",
             "profile_image_url_https": "profile_url3"
             ],
     "created": "2018-03-08T08:00:00GMT"
    }
    ]
    """.data(using: .utf8)!
    
    static let tweet =  try! JSONDecoder().decode(Tweet.self, from: tweetJson)
    static let tweets =  try! JSONDecoder().decode([Tweet].self, from: tweetsJson)
}
