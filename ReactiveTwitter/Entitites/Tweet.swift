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
    @NSManaged var id: Int64
    @NSManaged var text: String
    @NSManaged var name: String
    @NSManaged var created: Date?
    @NSManaged var imageUrl: String
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case text = "text"
        case name = "user.name"
        case created = "created_at"
        case imageUrl = "user.profile_image_url_https"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "MyManagedObject", in: context) else { fatalError() }
        self.init(entity: entity, insertInto: nil)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int64.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        name = try values.decode(String.self, forKey: .name)
        created = try values.decode(Date.self, forKey: .created)
        imageUrl = try values.decode(String.self, forKey: .imageUrl)
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension Tweet: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}

extension Tweet {
    static func ==(lhs: Tweet, rhs: Tweet) -> Bool {
        return lhs.id == rhs.id
    }
}
