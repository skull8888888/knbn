//
//  IdeaTableViewController.swift
//  iDeal
//
//  Created by Robert Kim on 12/28/15.
//  Copyright © 2015 Octopus. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit

class KanbanView: UIView {
    
    private var collectionView: UICollectionView!
    private var layout: KanbanCollectionViewLayout!
    private var scrollView: UIScrollView!
    
    var currentSection = 0
    var data = [[KanbanItem]]()
    
    private var isTransferingCellToDifferentSection = false
    private var currentlyMovingCell: NotesCollectionViewCell!
    private var currentlyMovingCellClone: NotesCollectionViewCell!
    
    weak var delegate: KanbanViewDelegate?
//    weak var layoutDelegate: KanbanViewLa
    
    
    private var differentSectionThreshold: CGFloat = 40.0
    private var differentSectionTimeThreshold: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = frame
        self.clipsToBounds = false
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.bounces = true
        self.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        layout = KanbanCollectionViewLayout()
//        layout.delegate =
        layout.cellHeight = (UIScreen.main.bounds.width - 48) / 2
        layout.cellWidth = UIScreen.main.bounds.width / 2 - 24
        layout.topPadding = 120.0
        layout.leftPadding = 24
        layout.numberOfCellsInRow = 2
    
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.scrollView.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, multiplier: CGFloat(3)).isActive = true
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "NotesCollectionViewCell", bundle: nil) , forCellWithReuseIdentifier: "Cell")
        collectionView.clipsToBounds = false
        collectionView.bounces = true
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        self.addGestureRecognizer(longPressGesture)
        
//        self.data = Model.shared.getData()
        collectionView.reloadData()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getLastIndexOfToDoSection() -> Int {
        return data[0].count
    }
    
}


extension KanbanView {

    func reload(data: [[KanbanItem]]){
        self.data = data
        self.collectionView.reloadData()
    }
    
}

extension KanbanView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if isTransferingCellToDifferentSection && indexPath.section != self.currentSection {
            return false
        }
        
        return true
        
    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        if isTransferingCellToDifferentSection && proposedIndexPath.section != self.currentSection {
            return IndexPath(row: self.data[self.currentSection].count, section: self.currentSection)
        }
        
        return proposedIndexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("MOVED CELL FROM \(sourceIndexPath) TO \(destinationIndexPath)")

        let sourceItem = data[sourceIndexPath.section][sourceIndexPath.item]

        data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        data[destinationIndexPath.section].insert(sourceItem, at: destinationIndexPath.item)
        
        delegate?.kanbanView(self, didChangeOrderOfItems: data)
        
//        Model.shared.saveItemsOrder(data)
        
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    
    @objc func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {

        switch(gesture.state) {

        case .began:
            
            guard let indexPath = self.collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            
            self.currentlyMovingCellClone = self.collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? NotesCollectionViewCell
            
            let item = data[indexPath.section][indexPath.item]
            delegate?.kanbanView(self, configureCell: self.currentlyMovingCellClone, with: item, at: indexPath)
            
            self.addSubview(self.currentlyMovingCellClone)
            
            let pointInCollectionView = gesture.location(in: self.collectionView)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? NotesCollectionViewCell {
                cell.isHidden = true
                self.currentlyMovingCell = cell
            }
        
            collectionView.beginInteractiveMovementForItem(at: indexPath)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.currentlyMovingCellClone.center = pointInCollectionView
            })
            
        case .changed:

            guard self.currentlyMovingCellClone != nil else { break }
            
            let pointInSelf = gesture.location(in: gesture.view)
            self.currentlyMovingCellClone.center = pointInSelf
            
            let pointInCollectionView = gesture.location(in: self.collectionView)
            collectionView.updateInteractiveMovementTargetPosition(pointInCollectionView)
            
            if !isTransferingCellToDifferentSection {

                let x = pointInCollectionView.x
                
                let maxX = CGFloat(self.currentSection + 1) * frame.width - differentSectionThreshold
                let minX = CGFloat(self.currentSection) * frame.width + differentSectionThreshold
                

                if x > maxX {
                    self.scrollToSectionWithIndex(self.currentSection + 1)
                } else if x < minX {
                    self.scrollToSectionWithIndex(self.currentSection - 1)
                }
                
            }

        case .ended:
            
            self.currentlyMovingCell.isHidden = false
            self.currentlyMovingCellClone.removeFromSuperview()
            self.collectionView.endInteractiveMovement()
            
            self.currentlyMovingCellClone = nil
            self.isTransferingCellToDifferentSection = false
            
        default:
            
            if self.currentlyMovingCellClone != nil {
                self.currentlyMovingCellClone.removeFromSuperview()
                self.currentlyMovingCellClone = nil
            }
            
            collectionView.cancelInteractiveMovement()
        }

    }

    func scrollToSectionWithIndex(_ index: Int){

        guard index != self.collectionView.numberOfSections else { return }
        guard index >= 0 else { return }
        
        currentSection = index
        isTransferingCellToDifferentSection = true

        UIView.animate(withDuration: 0.4, animations: {
            let point = CGPoint(x: CGFloat(index) * self.bounds.width, y: 0)
            self.scrollView.contentOffset = point
        })
        
    }
    
    func note(for indexPath: IndexPath) -> KanbanItem {
        return data[indexPath.section][indexPath.item]
    }
    
    func removeNote(at indexPath: IndexPath) {
        print("REMOVING AT ", indexPath)
        data[indexPath.section].remove(at: indexPath.item)
    }
    
    func insertNote(_ note: Note, at indexPath: IndexPath) {
        print("inserting AT ", indexPath)
        data[indexPath.section].insert(note, at: indexPath.item)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = data[indexPath.section][indexPath.item]
        
        delegate?.kanbanView(self, didSelectItem: item, at: indexPath)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.scrollView {

            let offset = scrollView.contentOffset.x / scrollView.frame.width
            
            if offset == floor(offset) {
                
                self.currentSection = Int(offset)
                
                delegate?.kanbanView(self, didScrollToSectionWithIndex: self.currentSection)
                
            }
            
        }
        
    }
    
}


extension KanbanView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NotesCollectionViewCell

        let item = data[indexPath.section][indexPath.item]
        
        delegate?.kanbanView(self, configureCell: cell, with: item, at: indexPath)
        
        return cell
        
    }
    
//    func configureCell(_ cell: NotesCollectionViewCell, indexPath: IndexPath) {
// 
////        let note = data[indexPath.section][indexPath.item]
////
////        cell.textLabel.text = note.text
////
////        let transform = CGAffineTransform(rotationAngle: note.angle)
////        cell.containerView.transform = transform
////        cell.underView.transform = transform
////
////        cell.containerView.backgroundColor = UIColor(hex: note.color)
////        cell.underView.backgroundColor = UIColor(hex: note.color)
//
//    }
    
}
