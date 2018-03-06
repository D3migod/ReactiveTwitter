//
//  Tweet.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

class Tweet {
    var id: Int64 = 0
    var text = ""
    var name = ""
    var created: Date?
    var imageUrl = ""
}

extension Tweet: Equatable {
    static func ==(lhs: Tweet, rhs: Tweet) -> Bool {
        return lhs.id == rhs.id
    }
}
