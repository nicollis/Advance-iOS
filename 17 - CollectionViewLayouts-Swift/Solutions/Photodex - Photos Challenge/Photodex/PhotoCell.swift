//
//  PhotoCell.swift
//  Photodex
//
//  Created by Michael Ward on 9/2/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit
import Photos

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!

    override func apply(_ attributes: UICollectionViewLayoutAttributes) {
        
        defer {
            super.apply(attributes)
        }
        
        guard let anchorableAttributes = attributes as? AnchorableAttributes else {
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            return
        }
        
        layer.anchorPoint = anchorableAttributes.anchorPoint
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
