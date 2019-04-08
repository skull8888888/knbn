//
//  BoardsTableViewController.swift
//  KNBN
//
//  Created by Robert Kim on 12/2/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import UIKit

class BoardsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Boards"
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }

}
