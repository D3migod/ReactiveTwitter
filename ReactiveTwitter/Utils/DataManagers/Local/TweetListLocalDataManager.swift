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
    
    // MARK: - Constants
    
    fileprivate static let tweetEntityName = "Tweet"
    fileprivate static let hashtagEntityName = "Hashtag"
    fileprivate static let sortingKey = "id"
    fileprivate static let defaultCoreDataLimit = 5000
    fileprivate static let defaultDeleteOnceOverload: Float = 0.1 // Percentage of entities to delete after reaching limit
    
    var coreDataLimit: Int!
    
    var deleteOnceOverload: Float!
    
    // MARK: - Functions
    init(coreDataLimit: Int = defaultCoreDataLimit, deleteOnceOverload: Float = defaultDeleteOnceOverload) {
        self.coreDataLimit = coreDataLimit
        self.deleteOnceOverload = deleteOnceOverload
    }
    
    /**
     Save tweets to CoreData
     
     - Parameter tweets
     */
    func save(_ tweets: [Tweet]) {
        guard let managedOC = CoreDataStore.backgroundManagedObjectContext else { return }
        do {
            try checkDidReachLimit(in: managedOC)
        } catch {
            // Do not save objects if it's impossible to retrieve them
            return
        }
        tweets.forEach{saveTweet($0, managedOC: managedOC)}
        managedOC.saveThrows()
    }
    
    /**
     Get tweets from CoreData satisfying query
     
     - Parameter query: query
     
     - Returns: Tweets satisfying query
     */
    func getTweets(for query: Query) throws -> [Tweet] {
        guard let managedOC = CoreDataStore.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }
        
        let fetchRequest: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
        fetchRequest.fetchLimit = query.0.2
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: TweetListLocalDataManager.sortingKey, ascending: false)]
        fetchRequest.predicate = buildPredicate(for: query)
        
        return try managedOC.fetch(fetchRequest)
    }
    
    /**
     Clear tweets from CoreData
     
     - Parameter tweets
     */
    func clear() throws {
        guard let managedOC = CoreDataStore.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }
        for value in [Tweet.self, Hashtag.self] {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: value))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try managedOC.execute(deleteRequest)
            } catch {
                print("Deletion executing failed")
                continue
            }
        }
        managedOC.saveThrows()
    }
    /**
     Save a tweet to CoreData
     
     - Parameter toBeSavedTweet: a tweet to be saved
     */
    fileprivate func saveTweet(_ toBeSavedTweet: Tweet, managedOC: NSManagedObjectContext) {
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
        }
    }
    
    /**
     Build predicate for fetch request
     
     - Parameter query: query to form predicate from
     
     - Returns: predicate
     */
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
        queryString += "ANY hashtags.text CONTAINS[cd] %@"
        argumentArray.append(searchString)
        
        return NSPredicate(format: queryString, argumentArray: argumentArray)
    }
    
    /**
     Deletes the oldest tweets if core data capacity limit is reached
     */
    fileprivate func checkDidReachLimit(in managedOC: NSManagedObjectContext) throws {
        let fetchCountExistingRequest: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
        guard let count = try? managedOC.count(for: fetchCountExistingRequest) else {
            print("Deletion error: Cannot determine current count of objects")
            throw PersistenceError.managedObjectContextNotFound
        }
        guard count >= coreDataLimit else { return }
        let fetchOldestRequest: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
        // If 1024 objects in store, 1000 is limit and 0.1 is delete per overload then
        // delete 1024 - 1000 + 1000 * 0.1 = 124 objects
        fetchOldestRequest.fetchLimit = count - coreDataLimit + Int((Float(coreDataLimit) * deleteOnceOverload).rounded(.up))
        fetchOldestRequest.sortDescriptors = [NSSortDescriptor(key: TweetListLocalDataManager.sortingKey, ascending: true)]
        guard let tweets = try? managedOC.fetch(fetchOldestRequest) else {
            print("Deletion error: Error fetching objects")
            return
        }
        tweets.forEach { tweet in
            tweet.hashtags?.forEach { hashtag in
                if hashtag.tweets.count == 1 {
                    managedOC.delete(hashtag)
                }
            }
            managedOC.delete(tweet)
        }
    }
}
