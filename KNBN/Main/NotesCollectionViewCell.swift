//
//  CollectionViewCell.swift
//  KNBN
//
//  Created by Robert Kim on 5/18/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        textLabel.adjustsFontSizeToFitWidth = true
    
    }
    
}
