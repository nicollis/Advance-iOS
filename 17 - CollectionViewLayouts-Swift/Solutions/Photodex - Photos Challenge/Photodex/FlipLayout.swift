//
//  FlipLayout
//  Photodex
//
//  Created by Michael Ward on 8/29/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class FlipLayout: UICollectionViewLayout {
    
    // MARK: - State and Metrics
    fileprivate var cellAttributes: [IndexPath:UICollectionViewLayoutAttributes] = [:]
    fileprivate var cellSize: CGSize = CGSize.zero
    fileprivate var cellCenter: CGPoint = CGPoint.zero
    
    fileprivate var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }

    fileprivate var currentOffset: CGFloat {
        return (collectionView!.contentOffset.y + collectionView!.contentInset.top)
    }
    
    fileprivate var currentCellIndex: Int {
        return max(0, Int(currentOffset / cellSize.height))
    }
    
    fileprivate var layoutRect: CGRect! {
        var rect = CGRect(origin: CGPoint.zero, size: collectionView!.frame.size)
        rect = UIEdgeInsetsInsetRect(rect, collectionView!.contentInset)
        return rect
    }
    
    fileprivate var shouldLayoutFromScratch: Bool = true
    
    // MARK: - Basic Layout Overrides
    
    override func prepare() {

        // Skip the layout preparation if the non-variable
        // attributes are still valid
        guard shouldLayoutFromScratch else {
            return
        }
        
        // Recalculate everything
        cellSize = CGSize(width: layoutRect.width, height: layoutRect.height / 2.0)
        cellCenter = CGPoint(x: layoutRect.width / 2.0, y: layoutRect.height / 2.0)
        
        cellAttributes = [:]
        for cellIndex in 0 ..< cellCount {
            let indexPath = IndexPath(item: cellIndex, section: 0)
            let attributes = AnchorableAttributes(forCellWith: indexPath)
            attributes.size = cellSize
            attributes.center = cellCenter
            attributes.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            cellAttributes[indexPath] = attributes
        }
        shouldLayoutFromScratch = false

    }
    
    override var collectionViewContentSize: CGSize {
        let contentWidth = layoutRect.width
        let contentHeight = (CGFloat(cellCount) * cellSize.height) + cellSize.height
        let contentSize = CGSize(width: contentWidth, height: contentHeight)
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        updateAttributesForItemAtIndexPath(indexPath)
        let attributes = cellAttributes[indexPath]
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for cellIndex in 0 ..< cellCount {
            let indexPath = IndexPath(item: cellIndex, section: 0)
            if let attributes = layoutAttributesForItem(at: indexPath) {
                allAttributes.append(attributes)
            }
        }
        return allAttributes
    }
    
    // MARK: - Layout Invalidation Overrides
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        
        if newBounds.size != collectionView!.bounds.size {
            shouldLayoutFromScratch = true
        }

        var indexPaths: [IndexPath] = []
        let index = currentCellIndex
        indexPaths.append(IndexPath(item: index, section: 0))
        if index > 0 {
            indexPaths.append(IndexPath(item: index - 1, section: 0))
        }
        
        if index < cellCount - 1 {
            indexPaths.append(IndexPath(item: index + 1, section: 0))
        }
        
        context.invalidateItems(at: indexPaths)
        return context
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            shouldLayoutFromScratch = true
        }
        super.invalidateLayout(with: context)
    }
    
    // MARK: - Transform Helpers
    
    fileprivate func updateAttributesForItemAtIndexPath(_ indexPath: IndexPath) {
        guard let attributes = cellAttributes[indexPath] else {
            return
        }
        
        switch (indexPath as NSIndexPath).item {
        case currentCellIndex:
            let relativeOffset = currentOffset / cellSize.height
            // fractionComplete is the fractional progress from one cell to the next
            let fractionComplete = max(0, modf(relativeOffset).1)
            attributes.transform3D = transform3DForFlipCompletion(fractionComplete)
            attributes.zIndex = 1
            attributes.isHidden = false
        case currentCellIndex + 1:
            attributes.transform3D = transform3DForFlipCompletion(0.0)
            attributes.zIndex = 0
            attributes.isHidden = false
        case currentCellIndex - 1:
            attributes.transform3D = transform3DForFlipCompletion(1.0)
            attributes.zIndex = 0
            attributes.isHidden = false
        default:
            attributes.transform3D = transform3DForFlipCompletion(0.0)
            attributes.zIndex = 0
            attributes.isHidden = true
        }
        
    }

    fileprivate func transform3DForFlipCompletion(_ fractionComplete: CGFloat) -> CATransform3D {
        
        var transform = CATransform3DIdentity

        // Translate by the currentOffset so that the cell remains centered relative to
        // the screen even as the content area scrolls
        transform = CATransform3DTranslate(transform, 0.0, currentOffset, 0.0)
        
        // The anchorpoint is now in the top-center of the cell, so rotate vertically
        // about the X axis to flip the cell
        let rotation = CGFloat.pi * fractionComplete
        transform = CATransform3DRotate(transform, rotation, 1, 0, 0)

        return transform
    }
}

extension FlipLayout: PhotoLayoutType {
    var imageSize: CGSize {
        return cellSize
    }
    
    var currentIndex: Int {
        return currentCellIndex
    }
}
