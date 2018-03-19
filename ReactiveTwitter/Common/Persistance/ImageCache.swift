//
//  ImageCache.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit

class ImageCache {
    
    /// Singleton
    public static let shared = ImageCache()
    
    // MARK: - Properties
    
    /// Cache to store images
    fileprivate var cache: NSCache<AnyObject, AnyObject>!
    
    /// Initializer
    fileprivate init() {
        cache = NSCache()
    }
    
    // MARK: - Functions
    
    /**
     Returns image stored in cache by 'identifier' keyword
     
     - Parameter identifier: key image is stored by
     
     - Returns: image
     */
    func getImage(with identifier: AnyObject) -> UIImage? {
        return cache.object(forKey: identifier) as? UIImage
    }
    
    /**
     Save image in cache by key 'identifier'
     
     - Parameter image: image to store
     
     - Parameter identifier: key image is stored by
     */
    func saveImage(_ image: UIImage, identifier: AnyObject) {
        cache.setObject(image, forKey: identifier)
    }
}
