//
//  NSManagedObjectContext+saveThrows.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 16.03.18.
//  Copyright © 2018 Bulat. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func saveThrows() { // ultimate save for any context including background one
        if self.hasChanges {
            do {
                try save()
            } catch let error {
                print("CoreData error occurred: \(error)")
            }
        }
    }
}
