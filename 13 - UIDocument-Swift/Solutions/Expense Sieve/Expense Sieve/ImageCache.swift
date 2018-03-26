//
//  ImageCache.swift
//  Expense Sieve
//
//  Created by Michael Ward on 8/22/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

import UIKit

protocol ImageCache {

    func image(forKey key: String) -> UIImage?
    
    func set(_ image: UIImage?, forKey imageID: String)
}
