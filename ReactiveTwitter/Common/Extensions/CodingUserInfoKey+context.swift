//
//  CodingUserInfoKey+context.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 10.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

extension CodingUserInfoKey {
    
//    passing context to decoder/encoder. Required for combining Coder and CoreData
    static let context = CodingUserInfoKey(rawValue: "context")!
}
