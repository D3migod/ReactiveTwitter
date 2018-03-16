//
//  PersistanceError.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation

/**
 Persistance error
 
 - managedObjectContextNotFound: context does not exist
 */
enum PersistenceError: Error {
    case managedObjectContextNotFound
}
