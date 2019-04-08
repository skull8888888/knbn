//
//  CollectionViewLayout.swift
//  KNBN
//
//  Created by Robert Kim on 11/19/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit


protocol KanbanCollectionViewLayoutDelegate: AnyObject {
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, cellFrameAt indexPath: IndexPath) -> CGRect
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, cellSizeAt indexPath: IndexPath) -> CGSize
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, paddingForCellAt indexPath: IndexPath) -> UIEdgeInsets
}

extension KanbanCollectionViewLayoutDelegate {
    
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, cellFrameAt indexPath: IndexPath) -> CGRect {

        let cellX = CGFloat(indexPath.section) * layout.sectionWidth + layout.sectionWidth / CGFloat(layout.numberOfCellsInRow) * CGFloat(indexPath.item % layout.numberOfCellsInRow)

        let cellY = CGFloat(floor(Double(indexPath.item / layout.numberOfCellsInRow))) * layout.cellHeight + layout.topPadding

        
        let cellFrame = CGRect(
            x: cellX,
            y: cellY,
            width: layout.cellWidth,
            height: layout.cellHeight)

        return cellFrame
        
    }
    
    func kanbanCollectionViewLayout(_ kanbanCollectionViewLayout: KanbanCollectionViewLayout, paddingForCellAt indexPath: IndexPath) -> UIEdgeInsets {
        return .zero
    }

}

class KanbanCollectionViewLayout: UICollectionViewLayout {

    var cellHeight: CGFloat = 0.0
    var cellWidth: CGFloat = 0.0
    var topPadding: CGFloat = 0.0
    var leftPadding: CGFloat = 0.0
    var bottomPadding: CGFloat = 0.0
    var numberOfCellsInRow: Int = 0
    
    var sectionWidth: CGFloat = 0
    
    weak var delegate: KanbanCollectionViewLayoutDelegate?
    
    private var cellAttributesDictionary = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize = .zero

    override var collectionViewContentSize: CGSize {
        get {
            return contentSize
        }
    }
    
    override func prepare() {
        
        if sectionWidth == 0 {
            sectionWidth = UIScreen.main.bounds.width 
        }
        
        var maxNumberOfItemsInSection = 0
        
        for section in 0 ..< collectionView!.numberOfSections {
            
            for item in 0 ..< collectionView!.numberOfItems(inSection: section) {
            
                let cellIndexPath = IndexPath(item: item, section: section)
                
                let cellX = sectionWidth * CGFloat(section) + CGFloat(item % self.numberOfCellsInRow) * self.cellWidth + self.leftPadding
                let cellY = CGFloat(floor(Double(item / self.numberOfCellsInRow))) * cellHeight + topPadding
                
                let cellFrame = CGRect(
                    x:cellX,
                    y: cellY,
                    width: self.cellWidth,
                    height: self.cellHeight)
                
                let cellLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                cellLayoutAttributes.frame = cellFrame
                
                cellAttributesDictionary[cellIndexPath] = cellLayoutAttributes
                
            }
            
            if collectionView!.numberOfItems(inSection: section) > maxNumberOfItemsInSection {
                maxNumberOfItemsInSection = collectionView!.numberOfItems(inSection: section)
            }
            
        }
        
        let contentWidth = CGFloat(collectionView!.numberOfSections) * sectionWidth
        let contentHeight = CGFloat(Int(maxNumberOfItemsInSection / self.numberOfCellsInRow) + 1) * cellHeight + (topPadding + bottomPadding)
        
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
