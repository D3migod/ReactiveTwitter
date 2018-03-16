//
//  Tweet.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import CoreData

class Tweet: NSManagedObject, Decodable {
    
    // MARK: - Constants
    
    fileprivate static let twitterDateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    
    // MARK: - Properties
    
    @NSManaged var id: Int64
    @NSManaged var text: String
    @NSManaged var name: String
    @NSManaged var created: Date?
    @NSManaged var imageUrl: String
    @NSManaged var hashtags: Set<Hashtag>?
    
    // MARK: - Decodable
    
    enum UserKeys: String, CodingKey {
        case name, imageUrl = "profile_image_url_https"
    }
    
    enum EntitiesKeys: String, CodingKey {
        case hashtags
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case text
        case user
        case created = "created_at"
        case entities
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: Tweet.self), in: context) else { fatalError() }
        self.init(entity: entity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        let userContainer = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        name = try userContainer.decode(String.self, forKey: .name)
        imageUrl = try userContainer.decode(String.self, forKey: .imageUrl)
        let hashtagsContainer = try container.nestedContainer(keyedBy: EntitiesKeys.self, forKey: .entities)
        hashtags = try hashtagsContainer.decodeIfPresent(Set<Hashtag>.self, forKey: .hashtags)
        
        let creationDateString = try container.decode(String.self, forKey: .created)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Tweet.twitterDateFormat
        created = dateFormatter.date(from: creationDateString)
    }
}

extension Tweet: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        var userContainer = container.nestedContainer(keyedBy: UserKeys.self, forKey: .user)
        try userContainer.encode(name, forKey: .name)
        try userContainer.encode(imageUrl, forKey: .imageUrl)
        var hashtagsContainer = container.nestedContainer(keyedBy: EntitiesKeys.self, forKey: .entities)
        try hashtagsContainer.encode(hashtags, forKey: .hashtags)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Tweet.twitterDateFormat
        try container.encode(dateFormatter.string(from: created ?? Date()), forKey: .created)
    }
}

extension Tweet {
    static func ==(lhs: Tweet, rhs: Tweet) -> Bool {
        return lhs.id == rhs.id
    }
}

