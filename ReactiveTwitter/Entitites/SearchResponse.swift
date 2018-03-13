//
//  SearchResponse.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 14.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

struct SearchResponse: Codable {
    var statuses: [Tweet]
}
