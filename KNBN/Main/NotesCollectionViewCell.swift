//
//  CollectionViewCell.swift
//  KNBN
//
//  Created by Robert Kim on 5/18/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        underView.dropShadow(cornerRadius: 8, shadowRadius: 8, y: 6, opacity: 0.2)
    
        containerView.layer.cornerRadius = 8
        underView.layer.cornerRadius = 8
        textLabel.adjustsFontSizeToFitWidth = true
    
    }
    
}
