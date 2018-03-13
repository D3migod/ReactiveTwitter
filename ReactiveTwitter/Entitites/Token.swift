//
//  Token.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 13.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

struct Token: Decodable {
    let token: String
    let tokenType: String
    
    init(token: String, tokenType: String) {
        self.token = token
        self.tokenType = tokenType
    }
    
    enum CodingKeys : String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let token: String = try container.decode(String.self, forKey: .token)
        let tokenType: String = try container.decode(String.self, forKey: .tokenType)
        self.init(token: token, tokenType: tokenType)
    }
}
