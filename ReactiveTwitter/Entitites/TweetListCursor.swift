//
//  Cursor.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

struct TweetListCursor {
    let maxId: Int64
    let sinceId: Int64
    
    init(max: Int64, since: Int64) {
        maxId = max
        sinceId = since
    }
    
    static var none: TweetListCursor { return TweetListCursor(max: Int64.max, since: 0) }
}

extension TweetListCursor: Equatable {
    static func ==(lhs: TweetListCursor, rhs: TweetListCursor) -> Bool {
        return lhs.maxId==rhs.maxId && lhs.sinceId==rhs.sinceId
    }
}
