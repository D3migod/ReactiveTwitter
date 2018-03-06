//
//  ImageCache.swift
//  ReactiveTwitter
//
//  Created by Bulat Galiev on 05.03.2018.
//  Copyright © 2018 Bulat. All rights reserved.
//

import UIKit

class ImageCache {
    public static let shared = ImageCache()
    
    fileprivate var cache: NSCache<AnyObject, AnyObject>!
    
    fileprivate init() {
        cache = NSCache()
    }
    
    func getImage(with identifier: AnyObject) -> UIImage? {
        return cache.object(forKey: identifier) as? UIImage
    }
}
