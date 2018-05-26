//
//  CollectionViewLayout.swift
//  KNBN
//
//  Created by Robert Kim on 11/19/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewLayout {
    
    
    let screen: CGRect = UIScreen.main.bounds
    
    var cellHeight: CGFloat = UIScreen.main.bounds.width / 2 - 24
    var cellWidth: CGFloat = UIScreen.main.bounds.width / 2 - 24
    
    var topPadding: CGFloat = 120
    
    
    var cellAttributesDictionary = [IndexPath: UICollectionViewLayoutAttributes]()
    var contentSize = CGSize.zero

    override var collectionViewContentSize: CGSize {
        get {
            return contentSize
        }
    }
    
    var dataSourceDidUpdate = true
    
    override func prepare() {
        
        collectionView?.bounces = false
        
        var maxNumberOfItemsInSection = 0
        
        for section in 0 ..< collectionView!.numberOfSections {
            
            for item in 0 ..< collectionView!.numberOfItems(inSection: section) {
                
                let cellIndexPath = IndexPath(item: item, section: section)
                
                var cellX:CGFloat = 0.0
        
                if item % 2 == 0 {
                    cellX = CGFloat(section) * screen.width + 24.0
                } else {
                    cellX = CGFloat(section) * screen.width + screen.width / 2
                }
                    
                let cellY = CGFloat(floor(Double(item) / 2.0)) * cellHeight + topPadding
    
                let cellFrame = CGRect(x: cellX, y: cellY, width: cellWidth, height: cellHeight)
                
                let cellLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                cellLayoutAttributes.frame = cellFrame
                
                cellAttributesDictionary[cellIndexPath] = cellLayoutAttributes
                
            }
            
            if collectionView!.numberOfItems(inSection: section) > maxNumberOfItemsInSection {
                maxNumberOfItemsInSection = collectionView!.numberOfItems(inSection: section)
            }
            
        }
        
        let contentWidth = CGFloat(collectionView!.numberOfSections) * screen.width
        let contentHeight = CGFloat(Int(maxNumberOfItemsInSection / 2) + 1) * cellHeight + 2 * topPadding
        contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        cellAttributesDictionary.removeAll()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesInRect = [UICollectionViewLayoutAttributes]()
        
        for cellAttrs in cellAttributesDictionary.values {
            if rect.intersects(cellAttrs.frame) {
                attributesInRect.append(cellAttrs)
            }
        }
        
        return attributesInRect
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributesDictionary[indexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    
}
