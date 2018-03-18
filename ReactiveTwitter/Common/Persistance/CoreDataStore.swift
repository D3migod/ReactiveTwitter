//
//  CoreDataStore.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 08.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStore {
    
    // MARK: - Properties
    
    static var persistentContainer: NSPersistentContainer? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer
        }
        return nil
    }
    
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.persistentStoreCoordinator
        }
        return nil
    }
    
    static var managedObjectModel: NSManagedObjectModel? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.managedObjectModel
        }
        return nil
    }
    
    static var managedObjectContext: NSManagedObjectContext? {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            return appDelegate.persistentContainer.viewContext
        }
        return nil
    }
    
    static var backgroundManagedObjectContext: NSManagedObjectContext? {
        if let privateBackgroundManagedObjectContext = privateBackgroundManagedObjectContext {
            try? privateBackgroundManagedObjectContext.setQueryGenerationFrom(.current)
            return privateBackgroundManagedObjectContext
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            privateBackgroundManagedObjectContext = appDelegate.persistentContainer.newBackgroundContext()
            privateBackgroundManagedObjectContext?.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return privateBackgroundManagedObjectContext
        }
        return nil
    }
    
    fileprivate static var privateBackgroundManagedObjectContext: NSManagedObjectContext?
}
