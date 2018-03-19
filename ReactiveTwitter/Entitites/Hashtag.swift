//
//  Hashtag.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 16.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import CoreData

class Hashtag: NSManagedObject, Codable {
    
    // MARK: - Properties
    
    @NSManaged var text: String
    @NSManaged var tweets: Set<Tweet>
    
    // MARK: - Codable
    
    enum HashtagCodingKeys : String, CodingKey {
        case text
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: Hashtag.self), in: context) else { fatalError() }
        self.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: HashtagCodingKeys.self)
        text = try values.decode(String.self, forKey: .text)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HashtagCodingKeys.self)
        try container.encode(text, forKey: .text)
    }
}
