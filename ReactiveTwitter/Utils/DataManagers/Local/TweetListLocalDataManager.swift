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
    
    var tweetsProducer: SignalProducer<[Tweet], NoError>!
    
    init() {
        tweetsProducer = SignalProducer<[Tweet], NoError>(value: []) // TODO: Remove the stub
    }
    
    func retrievePostList() throws -> [Tweet]  {
        
        guard let managedOC = CoreDataStore.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }
        
        let request: NSFetchRequest<Tweet> = NSFetchRequest(entityName: String(describing: Tweet.self))
        
        return try managedOC.fetch(request)
    }
    
    func saveTweet(id: Int, text: String, name: String, created: Date, imageUrl: String) throws {
        guard let managedOC = CoreDataStore.managedObjectContext else {
            throw PersistenceError.managedObjectContextNotFound
        }
        
        if let newTweet = NSEntityDescription.entity(forEntityName: TweetListLocalDataManager.tweetEntityName,
                                                    in: managedOC) {
            let tweet = Tweet(entity: newTweet, insertInto: managedOC)
            tweet.id = Int64(id)
            tweet.text = text
            tweet.name = name
            tweet.created = created
            tweet.imageUrl = imageUrl
            try managedOC.save()
        }
        throw PersistenceError.couldNotSaveObject
        
    }
}
