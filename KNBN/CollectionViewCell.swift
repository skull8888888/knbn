//
//  CollectionViewCell.swift
//  KNBN
//
//  Created by Robert Kim on 5/18/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!

    var angle: CGFloat! {
        didSet{
            let transform = CGAffineTransform(rotationAngle: angle)
            
            underView.transform = transform
            containerView.transform = transform
        }
    }
    
    var color: UIColor! {
        didSet {
            underView.backgroundColor = color
            containerView.backgroundColor = color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        underView.layer.shadowColor = UIColor.black.cgColor
        underView.layer.shadowOffset = CGSize(width: 0, height: 2)
        underView.layer.shadowOpacity = 0.5
        underView.layer.shadowRadius = 2
        underView.layer.cornerRadius = 2
        underView.layer.shouldRasterize = true
        
        containerView.layer.cornerRadius = 2
        
        textLabel.adjustsFontSizeToFitWidth = true
    
    }
    
}
