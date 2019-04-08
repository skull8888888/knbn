
//
//  KanbanViewDelegate.swift
//  KNBN
//
//  Created by Robert Kim on 7/4/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import Foundation
import UIKit

protocol KanbanItem {
    
}

protocol KanbanViewDelegate: AnyObject {
    
    func kanbanView(_ kanbanView: KanbanView, didSelectItem item: KanbanItem, at indexPath: IndexPath)
    func kanbanView(_ kanbanView: KanbanView, didScrollToSectionWithIndex index: Int)
    func kanbanView(_ kanbanView: KanbanView, didChangeOrderOfItems data: [[KanbanItem]])
    func kanbanView(_ kanbanView: KanbanView, configureCell cell: UICollectionViewCell, with item: KanbanItem, at indexPath: IndexPath)
    
}

extension KanbanViewDelegate {
    
    func kanbanView(_ kanbanView: KanbanView, didSelectItem item: KanbanItem, at indexPath: IndexPath) {}
    func kanbanView(_ kanbanView: KanbanView, didScrollToSectionWithIndex index: Int) {}
    func kanbanView(_ kanbanView: KanbanView, didChangeOrderOfItems data: [[KanbanItem]]) {}
    
}
