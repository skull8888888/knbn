//
//  ViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/14/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit
import SideMenu

class MainViewController: UIViewController {
    
    var kanbanView: KanbanView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        kanbanView = KanbanView(frame: .zero)
        self.view.addSubview(kanbanView)
        
        kanbanView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.leading.top.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.leading.top.trailing.bottom.equalTo(self.view)
            }
        }
        kanbanView.delegate = self
        kanbanView.reload(data: Model.shared.getData())

        let addNoteButton = UIButton(frame: .zero)
        self.view.addSubview(addNoteButton)
        addNoteButton.snp.makeConstraints { (make) in
            
            make.leading.equalTo(self.view).offset(32)
            make.trailing.equalTo(self.view).offset(-32)
            make.height.equalTo(48)
            
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            } else {
                make.bottom.equalTo(self.view.snp.bottom).offset(-32)
            }
        }
        
        addNoteButton.setTitle("NOTE", for: .normal)
        addNoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(rawValue: 400))
        addNoteButton.setTitleColor(UIColor.subtitle, for: .normal)
        addNoteButton.backgroundColor = UIColor.background
        addNoteButton.addTarget(self, action: #selector(presentNewNoteVC), for: .touchUpInside)
        addNoteButton.layer.cornerRadius = 8
        addNoteButton.dropShadow()
        addNoteButton.layer.shouldRasterize = false
        
        self.view.bringSubviewToFront(addNoteButton)
       
        navigationItem.title = "TO DO"
     
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
//        let menuButtonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(didTappedMenuButtonItem))
//        self.navigationItem.leftBarButtonItem = menuButtonItem
        
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: BoardsTableViewController())
        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
        // let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuShadowColor = UIColor.clear
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.kanbanView.reload(data: Model.shared.getData())
    }
    
    @objc func didTappedMenuButtonItem(){
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func presentNewNoteVC(){
        let newNoteVC = NewNoteViewController()
        let lastIndex = kanbanView.getLastIndexOfToDoSection()
        newNoteVC.mode = .create(lastIndex)
        self.present(UINavigationController(rootViewController: newNoteVC), animated: true, completion: nil)
    }
    
}

extension MainViewController: KanbanViewDelegate {
   
    func kanbanView(_ kanbanView: KanbanView, didSelectItem item: KanbanItem, at indexPath: IndexPath) {
        
        let newNoteVC = NewNoteViewController()
        newNoteVC.mode = .edit(item as! Note)
        self.present(UINavigationController(rootViewController: newNoteVC), animated: true, completion: nil)
        
    }
    
    func kanbanView(_ kanbanView: KanbanView, didScrollToSectionWithIndex index: Int) {
        
        switch index {
        case 0: navigationItem.title = "TO DO"
        case 1: navigationItem.title = "PROGRESS"
        case 2: navigationItem.title = "DONE"
        default: break
        }
        
    }
    
    func kanbanView(_ kanbanView: KanbanView, didChangeOrderOfItems data: [[KanbanItem]]) {
        Model.shared.saveItemsOrder(data as! [[Note]])
    }
    
    func kanbanView(_ kanbanView: KanbanView, configureCell cell: UICollectionViewCell, with item: KanbanItem, at indexPath: IndexPath) {
        
        guard let note = item as? Note, let cell = cell as? NotesCollectionViewCell else { return }
    
        cell.textLabel.text = note.text
        
        let transform = CGAffineTransform(rotationAngle: note.angle)
        cell.containerView.transform = transform
        cell.underView.transform = transform
        
        cell.containerView.backgroundColor = UIColor(hex: note.color)
        cell.underView.backgroundColor = UIColor(hex: note.color)

    }
    
}
