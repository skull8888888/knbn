//
//  BoardsTableViewCell.swift
//  KNBN
//
//  Created by Robert Kim on 12/2/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import UIKit

class BoardsTableViewCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedView.layer.cornerRadius = 4
        selectedView.backgroundColor = .clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
