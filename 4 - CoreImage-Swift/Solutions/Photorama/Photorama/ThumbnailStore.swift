//
//  ThumbnailStore.swift
//  Photorama
//
//  Created by Michael Ward on 9/14/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ThumbnailStore {
    
    private let thumbnailCache = NSCache<NSString,UIImage>()
    
    func thumbnail(forKey key: NSString) -> UIImage? {
        return thumbnailCache.object(forKey: key)
    }
    
    func setThumbnail(image: UIImage, forKey key: NSString) {
        thumbnailCache.setObject(image, forKey: key)
    }
    
    func clearThumbnails() {
        thumbnailCache.removeAllObjects()
    }
    
}
