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

protocol NotesCollectionViewCellDelegate: AnyObject {
    func didSelectNote(_ note: Note)
    func didScrollToSection(with index: Int)
}

class NotesCollectionView: UIView {
    
    private var collectionView: UICollectionView!
    private var scrollView: UIScrollView!
    
    var currentSection = 0
    
    var data = [[Note]]()
    
    private var isTransferingCellToDifferentSection = false
    
    private var currentlyMovingCell: NotesCollectionViewCell!
    private var currentlyMovingItem: Note!
    private var currentlyMovingIndexPath: IndexPath! {
        didSet {
            
            guard let currentlyMovingIndexPath = currentlyMovingIndexPath else { return }
            
            if let cell = collectionView.cellForItem(at: currentlyMovingIndexPath) as? NotesCollectionViewCell {
                self.currentlyMovingCell = cell
                currentlyMovingItem = data[currentlyMovingIndexPath.section][currentlyMovingIndexPath.item]
            } else {
                self.currentlyMovingCell = nil
                self.currentlyMovingItem = nil
            }
            
        }
        
    }
    
    weak var delegate: NotesCollectionViewCellDelegate?
    
    private var differentSectionThreshold: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.clipsToBounds = false
        
        scrollView = UIScrollView(frame: .zero)
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.leading.top.trailing.bottom.equalTo(self.safeAreaLayoutGuide)
            } else {
                make.leading.top.trailing.bottom.equalTo(self)
            }
        }
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        
        let layout = CollectionViewLayout()
    
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.scrollView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView.snp.height)
            make.width.equalTo(self.scrollView.snp.width).multipliedBy(3)
        }
        
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NotesCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "NotesCollectionViewCell", bundle: nil) , forCellWithReuseIdentifier: "Cell")
        collectionView.clipsToBounds = false
        collectionView.bounces = true
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        
        self.data = Model.shared.getData()
        collectionView.reloadData()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reloadData(){

        self.data = Model.shared.getData()
        collectionView.reloadData()

    }
    
    func getLastIndexOfToDoSection() -> Int {
        return data[0].count
    }
    
}


extension NotesCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        print("MOVED CELL FROM \(sourceIndexPath) TO \(destinationIndexPath)")

        let sourceItem = data[sourceIndexPath.section][sourceIndexPath.item]

        data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        data[destinationIndexPath.section].insert(sourceItem, at: destinationIndexPath.item)
        
        Model.shared.saveItemsOrder(data)
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

            self.currentlyMovingIndexPath = indexPath
            collectionView.beginInteractiveMovementForItem(at: indexPath)

            let point = gesture.location(in: gesture.view)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.currentlyMovingCell.center = point
            })
            
        case .changed:

            let point = gesture.location(in: gesture.view)
            collectionView.updateInteractiveMovementTargetPosition(point)

            if !isTransferingCellToDifferentSection && currentlyMovingIndexPath != nil {

                if (point.x > frame.width - differentSectionThreshold && point.x < frame.width) {
                    self.scrollToSectionWithIndex(1)
                } else if (point.x > 2 * frame.width - differentSectionThreshold && point.x < 2 * frame.width) {
                    self.scrollToSectionWithIndex(2)
                } else if (point.x > frame.width && point.x < frame.width + differentSectionThreshold) {
                    self.scrollToSectionWithIndex(0)
                } else if (point.x > 2 * frame.width && point.x < 2 * frame.width + differentSectionThreshold) {
                    self.scrollToSectionWithIndex(1)
                }

            }

        case .ended:

            print("ENDED FOR ", currentlyMovingIndexPath)

            self.collectionView.endInteractiveMovement()
            
            self.currentlyMovingItem = nil
            self.isTransferingCellToDifferentSection = false
            
        default:
            collectionView.cancelInteractiveMovement()
        }

    }

    func scrollToSectionWithIndex(_ index: Int){

        currentSection = index
        isTransferingCellToDifferentSection = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.performTransitionToNewSection()
        }
        
        UIView.animate(withDuration: 0.4, animations: {
            let point = CGPoint(x: CGFloat(index) * self.bounds.width, y: 0)
            self.scrollView.contentOffset = point
        })
        

    }
    
    func performTransitionToNewSection(){
        
        guard let currentlyMovingIndexPath = currentlyMovingIndexPath, isTransferingCellToDifferentSection else {
            print("WAS MOVING TOO FAST")
            return
        }
        
        print("PERFORMING TRANSITION TO DIFFERENT SECTION")
        // saving last position of the currently moving cell
        let lastPosition = currentlyMovingCell.frame.origin
        collectionView.endInteractiveMovement()
        currentlyMovingCell.isHidden = true
        
        
        let insertIndexPath = IndexPath(item: self.data[self.currentSection].count, section: self.currentSection)
        
        // remove cell from previous position and insert clone cell at the end of the new section
        collectionView.performBatchUpdates({

            guard let note = currentlyMovingItem else { return }

            removeNote(at: currentlyMovingIndexPath)
            insertNote(note, at: insertIndexPath)
            collectionView.deleteItems(at: [currentlyMovingIndexPath])
            collectionView.insertItems(at: [insertIndexPath])

        }) { _ in
            print(self.data[2])
            Model.shared.saveItemsOrder(self.data)
        }
        
        self.currentlyMovingIndexPath = insertIndexPath
        
        self.collectionView.beginInteractiveMovementForItem(at: insertIndexPath)
        self.collectionView.updateInteractiveMovementTargetPosition(lastPosition)
        
    }
    
    func note(for indexPath: IndexPath) -> Note {
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
        delegate?.didSelectNote(data[indexPath.section][indexPath.item])
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            
            let offset = scrollView.contentOffset.x / scrollView.frame.width
            
            if offset == floor(offset) {
                
                delegate?.didScrollToSection(with: Int(offset))
                
            }
            
        }
    }
    
}


extension NotesCollectionView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NotesCollectionViewCell
        
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: NotesCollectionViewCell, indexPath: IndexPath) {
        
        let note = data[indexPath.section][indexPath.item]
    
        cell.textLabel.text = note.text
        
        let transform = CGAffineTransform(rotationAngle: note.angle)
        cell.containerView.transform = transform
        cell.underView.transform = transform

        cell.containerView.backgroundColor = UIColor(hex: note.color)
        cell.underView.backgroundColor = UIColor(hex: note.color)
        
    }
    
}
