//
//  ImageCache.swift
//  Expense Sieve
//
//  Created by Michael Ward on 8/22/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ImageCache {
    
    private let cache = NSCache<NSString,UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage?, forKey imageID: String) {
        if let image = image {
            cache.setObject(image, forKey: imageID as NSString)
        } else {
            cache.removeObject(forKey: imageID as NSString)
        }
    }
}
