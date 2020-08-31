//
//  CollectionViewLayout.swift
//  KNBN
//
//  Created by Robert Kim on 11/19/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit


protocol KanbanCollectionViewLayoutDelegate: AnyObject {
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, cellHeightAt indexPath: IndexPath) -> CGFloat
    func kanbanCollectionViewLayout(_ layout: KanbanCollectionViewLayout, paddingForCellAt indexPath: IndexPath) -> UIEdgeInsets
}

extension KanbanCollectionViewLayoutDelegate {
        
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
                
                var cellX: CGFloat = 0;
                var cellY: CGFloat = 0;
                var cellWidth: CGFloat = self.cellWidth;
                let cellHeight: CGFloat = delegate?.kanbanCollectionViewLayout(self, cellHeightAt: cellIndexPath) ?? self.cellHeight;
                
                if section != 1 {
                    
                    if(item >= 2) {
                        guard let prevFrame = cellAttributesDictionary[IndexPath(item: item - 2, section: section)]?.frame else { continue }
                        
                        cellY = prevFrame.maxY
                        cellX = prevFrame.minX
                
                    } else {

                        cellX = sectionWidth * CGFloat(section) + CGFloat(item % self.numberOfCellsInRow) * self.cellWidth + self.leftPadding
                        cellY = topPadding
                    }
                } else {
                    
                    if item == 0 {
                        
                        cellX = CGFloat(section) * sectionWidth + leftPadding
                        cellY = topPadding
                        cellWidth = self.cellWidth * 2
                        
                    } else if item >= 3 {
                        guard let prevFrame = cellAttributesDictionary[IndexPath(item: item - 2, section: section)]?.frame else { continue }
                                           
                        cellY = prevFrame.maxY
                        cellX = prevFrame.minX
                                   
                    } else {
                        guard let firstCell = cellAttributesDictionary[IndexPath(item: 0, section: section)]?.frame else { continue }
                        
                        cellX = sectionWidth * CGFloat(section) + CGFloat((item + 1) % self.numberOfCellsInRow) * self.cellWidth + self.leftPadding
                        cellY = firstCell.maxY
                    
                    }
                    
                }
        
                let cellFrame = CGRect(
                                    x:cellX,
                                    y: cellY,
                                    width: cellWidth,
                                    height: cellHeight)
                                   
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
