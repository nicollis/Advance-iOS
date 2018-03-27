//
//  ThumbnailStore.swift
//  Photorama
//
//  Created by Nicholas Ollis on 3/27/18.
//  Copyright © 2018 Big Nerd Ranch. All rights reserved.
//

import UIKit

class ThumbnailStore {
    
    private let thumbnailCache = NSCache<NSString,UIImage>()
    
    func thumbnail(forKey key: NSString) -> UIImage? {
        return thumbnailCache.object(forKey: key)
    }
    
    func setThumbnail(image: UIImage, forKey key: NSString){
        thumbnailCache.setObject(image, forKey: key)
    }
    
    func clearThumbnails() {
        thumbnailCache.removeAllObjects()
    }
}
