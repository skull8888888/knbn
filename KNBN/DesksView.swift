//
//  DesksView.swift
//  KNBN
//
//  Created by Robert Kim on 5/31/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class DesksView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    
    var data: [Desk] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil) ,forCellReuseIdentifier: "Cell")
        self.addSubview(tableView)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        
        
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
