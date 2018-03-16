//
//  TweetListDataManager.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import ReactiveSwift
import Result
import CoreData

class TweetListLocalDataManager: TweetListLocalDataManagerProtocol {

    fileprivate static let tweetEntityName = "Tweet"
    fileprivate static let hashtagEntityName = "Hashtag"
    
    fileprivate func saveTweet(_ toBeSavedTweet: Tweet) {
        CoreDataStore.persistentContainer?.performBackgroundTask({ managedOC in
        
        if let newTweet = NSEntityDescription.entity(forEntityName: TweetListLocalDataManager.tweetEntityName,
                                                    in: managedOC) {
            let tweet = Tweet(entity: newTweet, insertInto: managedOC)
            tweet.id = toBeSavedTweet.id
            tweet.text = toBeSavedTweet.text
            tweet.name = toBeSavedTweet.name
            tweet.created = toBeSavedTweet.created
            tweet.imageUrl = toBeSavedTweet.imageUrl
            let hashtags = tweet.mutableSetValue(forKey: "hashtags")
            toBeSavedTweet.hashtags?.forEach({ (toBeSavedHashtag) in
                if let newHashtag = NSEntityDescription.entity(forEntityName: TweetListLocalDataManager.hashtagEntityName,
                                                             in: managedOC) {
                    let hashtag = Hashtag(entity: newHashtag, insertInto: managedOC)
                    hashtag.text = toBeSavedHashtag.text
                    hashtags.add(hashtag)
                }
            })
            managedOC.saveThrows()
        }
        })
        
    }
    
    func save(_ tweets: [Tweet]) {
        tweets.forEach{saveTweet($0)}
    }
    
    func getTweets(for query: Query) throws -> [Tweet] {
        guard let managedOC = CoreDataStore.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }
        
        let fetchRequest: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
        fetchRequest.fetchLimit = query.0.2
        fetchRequest.predicate = buildPredicate(for: query)

        return try managedOC.fetch(fetchRequest)
    }
    
    fileprivate func buildPredicate(for query: Query) -> NSPredicate {
        let ((minId, maxId, _), searchString) = query
        var queryString = ""
        var argumentArray = [Any]()
        if let maxId = maxId {
            queryString += "id <= %@ AND "
            argumentArray.append(maxId)
        }
        if let minId = minId {
            queryString += "id > %@ AND "
            argumentArray.append(minId)
        }
        queryString += "ANY hashtags.text == %@"
        argumentArray.append(searchString)
        
        return NSPredicate(format: queryString, argumentArray: argumentArray)
    }
}
