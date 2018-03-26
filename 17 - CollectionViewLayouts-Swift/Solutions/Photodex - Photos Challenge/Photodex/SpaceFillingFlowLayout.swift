//
//  SpaceFillingFlowLayout.swift
//  Photodex
//
//  Created by Michael Ward on 8/25/15.
//  Copyright © 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class SpaceFillingFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - External Configuration
    
    @IBInspectable var minCellSize: CGSize = CGSize(width: 96, height: 96) {
        didSet {
            invalidateLayout()
        }
    }
    
    @IBInspectable var cellSpacing: CGFloat = 8 {
        didSet {
            invalidateLayout()
        }
    }
    
    // MARK: - Internal Metrics
    
    fileprivate var cellCount: Int {
        return collectionView!.dataSource!.collectionView(collectionView!, numberOfItemsInSection: 0)
    }
    fileprivate var contentSize: CGSize = CGSize.zero
    fileprivate var columns: Int = 0
    fileprivate var rows: Int = 0
    fileprivate var cellSize: CGSize = CGSize.zero
    fileprivate var cellCenterPoints: [CGPoint] = []
    
    // MARK: - Layout Overrides
    
    override func prepare() {
        let collectionViewWidth = collectionView!.frame.size.width
        
        // Calculate the number of rows and columns (yay algebra!)
        columns = Int( (collectionViewWidth - cellSpacing) / (minCellSize.width + cellSpacing) )
        rows = Int( ceil(Double(cellCount) / Double(columns)) )
        
        // Take the remaining gap and divide it among the existing columns
        let innerWidth = (CGFloat(columns) * (minCellSize.width + cellSpacing)) + cellSpacing
        let extraWidth = collectionViewWidth - innerWidth
        let cellGrowth = extraWidth / CGFloat(columns)
        cellSize.width = floor(minCellSize.width + cellGrowth)
        cellSize.height = cellSize.width
        
        // For each cell, calculate its center point
        for itemIndex in 0 ..< cellCount {
            // Locate the cell's position in the grid
            let coordBreakdown = modf(CGFloat(itemIndex) / CGFloat(columns))
            let row = Int(coordBreakdown.0) + 1
            let col = Int(round(coordBreakdown.1 * CGFloat(columns))) + 1
            
            // Calculate the actual centerpoint of the cell, given its position
            var cellBottomRight = CGPoint.zero
            cellBottomRight.x = CGFloat(col) * (cellSpacing + cellSize.width)
            cellBottomRight.y = CGFloat(row) * (cellSpacing + cellSize.height)
            
            var cellCenter = CGPoint.zero
            cellCenter.x = cellBottomRight.x - (cellSize.width / 2.0)
            cellCenter.y = cellBottomRight.y - (cellSize.height / 2.0)
            
            cellCenterPoints.append(cellCenter)
        }
        print("columns: \(columns), rows: \(rows)")
        print("cell size: \(cellSize)")
    }
    
    override var collectionViewContentSize: CGSize {
        // Calculate and cache the total content size
        let contentWidth = (cellSize.width + cellSpacing) * CGFloat(columns) + cellSpacing
        let contentHeight = (cellSize.height + cellSpacing) * CGFloat(rows) + cellSpacing
        let contentSize = CGSize(width: contentWidth, height: contentHeight)
        print("content size: \(contentSize), collection size: \(collectionView!.frame.size)")
        return contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        attributes.size = cellSize
        attributes.center = cellCenterPoints[(indexPath as NSIndexPath).row]
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        for itemIndex in 0 ..< cellCount {
            if rect.contains(cellCenterPoints[itemIndex]) {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let attributes = layoutAttributesForItem(at: indexPath)!
                allAttributes.append(attributes)
            }
        }
        
        return allAttributes
    }
    
}

extension SpaceFillingFlowLayout: PhotoLayoutType {
    
    var imageSize: CGSize {
        return cellSize
    }
    
    var currentIndex: Int {
        let visibleIndices = collectionView!.indexPathsForVisibleItems
        if visibleIndices.count == 0 { return 0 }
        
        let middleIndex = (visibleIndices.last! as IndexPath).row - Int(visibleIndices.count / 2)
        return middleIndex
    }
}
