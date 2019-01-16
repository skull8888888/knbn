//
//  IdeaTableViewController.swift
//  iDeal
//
//  Created by Robert Kim on 12/28/15.
//  Copyright © 2015 Octopus. All rights reserved.
//

import UIKit
import RealmSwift

protocol BoardCollectionViewCellDelegate {
    func scrollTo(point: CGPoint)
    func didSelectNote(_ note: Note)
}

class BoardCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var collectionView: UICollectionView!
    
    var selectedRowIndex: IndexPath!
    var shouldReloadCollectionView = false
    
    var cellMoved = false
    var currentSection = 0
    
    var data = [[Note]]()
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    var beginTransferNext = false

    var cellForMovement: CollectionViewCell!
    var indexForMovement: IndexPath!
    
    var delegate: BoardCollectionViewCellDelegate!
    
    var screen = UIScreen.main.bounds
    
    var realm: Realm!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        
        realm = try! Realm()
        
        let toDo = Array(realm.objects(Note.self).filter("type = 'ToDo'").sorted(byKeyPath: "index"))
        let progress = Array(realm.objects(Note.self).filter("type = 'Progress'").sorted(byKeyPath: "index"))
        let done = Array(realm.objects(Note.self).filter("type = 'Done'").sorted(byKeyPath: "index"))
        
        if toDo.count == 0 && progress.count == 0 && done.count == 0 {
            
            data = [
                [],
                [
                Note(value: [
                    "text": "Add new tasks by tapping panel below. They will appear on the “ToDo” board.",
                    "angle": -0.01815949566662312,
                    "type": "Progress",
                    "index": 0,
                    "color": "80CBC4"
                ]),
                Note(value: [
                    "text": "To delete or edit tasks’ text or color simply tap on sticker with your task.",
                    "angle": 0.01795195788145065,
                    "type": "Progress",
                    "index": 1,
                    "color": "C5E1A5"
                    ])
                ,
                Note(value: [
                    "text": "To transfer task from one board to another simply long-press on the sticker that you want to move and drag it to either right or left corner.",
                    "angle": 0.01805512979626656,
                    "type": "Progress",
                    "index": 2,
                    "color": "FFF59D"
                    ])
                ],
                []
            ]
            
            for note in data[1] {
                try! realm.write {
                    realm.add(note)
                }
            }
            
        } else {
            data = [
                toDo,
                progress,
                done
            ]
        }
        
        let layout: UICollectionViewLayout = CollectionViewLayout()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 100,height: 50)
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil) , forCellWithReuseIdentifier: "Cell")
        collectionView.clipsToBounds = false
        collectionView.showsHorizontalScrollIndicator = false
    
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongGesture(_:)))
        
        collectionView.addGestureRecognizer(longPressGesture)
        
        self.addSubview(collectionView)
        addLabels()
        self.clipsToBounds = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLabels(){
        
        for (index, label) in ["ToDo", "Progress", "Done"].enumerated() {
            let titleLabel = UILabel(frame: CGRect(x: CGFloat(index) * screen.width, y: 46, width: screen.width, height: 50))
            titleLabel.text = label
            titleLabel.textColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 40, weight: 400)
            self.addSubview(titleLabel)
        }
    }
    
    func reloadData(){
        let toDo = Array(realm.objects(Note.self).filter("type = 'ToDo'").sorted(byKeyPath: "index"))
        let progress = Array(realm.objects(Note.self).filter("type = 'Progress'").sorted(byKeyPath: "index"))
        let done = Array(realm.objects(Note.self).filter("type = 'Done'").sorted(byKeyPath: "index"))
        
        data = [
            toDo,
            progress,
            done
        ]
        collectionView.reloadData()
        saveCellsOrder()
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        cellMoved = true
        
        let sourceItem = data[sourceIndexPath.section][sourceIndexPath.item]
       
        if sourceIndexPath.section == destinationIndexPath.section {
            data[sourceIndexPath.section][sourceIndexPath.item] = data[sourceIndexPath.section][destinationIndexPath.item]
            data[sourceIndexPath.section][destinationIndexPath.item] = sourceItem
        } else {
            data[destinationIndexPath.section].insert(sourceItem, at: destinationIndexPath.item)
            data[sourceIndexPath.section].remove(at: sourceIndexPath.item)
        }
        
        saveCellsOrder()
        
    }
    
    func saveCellsOrder(){
        for (sectionIndex, section) in ["ToDo", "Progress", "Done"].enumerated() {
            
            for (itemIndex, item) in data[sectionIndex].enumerated() {
                
                let note = realm.objects(Note.self).filter("text = %@", item.text).first
                
                try! realm.write {
                    note?.index = itemIndex as NSNumber
                    note?.type = section as NSString
                }
                
            }

        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleLongGesture(_ gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case .began:
            
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            
            collectionView.collectionViewLayout.invalidateLayout()
                    
            guard let cell = collectionView.cellForItem(at: selectedIndexPath) as? CollectionViewCell else {
                return
            }
        
            cellForMovement = cell
            indexForMovement = selectedIndexPath
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            let point = gesture.location(in: gesture.view)
            collectionView.updateInteractiveMovementTargetPosition(point)
        case .changed:
        
            let point = gesture.location(in: gesture.view)
            
            if beginTransferNext == false {
                if (point.x > screen.width - 20 && point.x < screen.width) {
                    currentSection = 1
                    delegate.scrollTo(point: CGPoint(x: screen.width, y: 0))
                    beginTransferNext = true
                } else if (point.x > 2 * screen.width - 20 && point.x < 2 * screen.width) {
                    currentSection = 2
                    delegate.scrollTo(point: CGPoint(x: 2 * screen.width, y: 0))
                    beginTransferNext = true
                } else if (point.x > screen.width && point.x < screen.width + 20) {
                    currentSection = 0
                    delegate.scrollTo(point: CGPoint(x: 0, y: 0))
                    beginTransferNext = true
                } else if (point.x > 2 * screen.width && point.x < 2 * screen.width + 20) {
                    currentSection = 1
                    delegate.scrollTo(point: CGPoint(x: screen.width, y: 0))
                    beginTransferNext = true
                }
            } else {
                
            }
            
            collectionView.updateInteractiveMovementTargetPosition(point)
            collectionView.collectionViewLayout.invalidateLayout()
        case .ended:
           
            collectionView.endInteractiveMovement()
            
            if cellMoved == false && beginTransferNext {
                
                let item = data[indexForMovement.section][indexForMovement.item]
                
                data[indexForMovement.section].remove(at: indexForMovement.item)
                data[currentSection].append(item)
                
                let toIndexPath = IndexPath(item: collectionView.numberOfItems(inSection: currentSection), section: currentSection)
                
                collectionView.moveItem(at: indexForMovement, to: toIndexPath)
                
                print("moving")
                
                cellMoved = false
                saveCellsOrder()
            } else {
                cellMoved = false
            }
            
            
            beginTransferNext = false
    
        default:
            collectionView.cancelInteractiveMovement()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectNote(data[indexPath.section][indexPath.item])
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

        configureCell(cell, indexPath: indexPath)

        return cell
    }

    func configureCell(_ cell: CollectionViewCell, indexPath: IndexPath) {

        let note = data[indexPath.section][indexPath.item]
    
        cell.textLabel.text = note.text as String
        cell.angle = CGFloat(note.angle)
        cell.color = UIColor(hex: note.color as String)
        
        cell.isHidden = false

    }
    
}

