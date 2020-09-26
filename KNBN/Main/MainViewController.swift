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
    
    enum SectionTitle: String {
        case todo = "To Do"
        case progress = "Progress"
        case done = "Done Today"
    }
    
    var kanbanView: KanbanView!
    
    var isFirstRun = true;
    
    var taskCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                self.view.backgroundColor = .white
            } else {
                self.view.backgroundColor = .black
            }
        } else {
            self.view.backgroundColor = .white
        }
        
        kanbanView = KanbanView(frame: .zero)
        self.view.addSubview(kanbanView)
        
        
        kanbanView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        kanbanView.delegate = self
        kanbanView.reload(data: Model.shared.getData())
        kanbanView.scrollToSectionWithIndex(1)

        
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
        
        addNoteButton.setTitle("task", for: .normal)
        addNoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        addNoteButton.setTitleColor(UIColor.subtitle, for: .normal)
        addNoteButton.backgroundColor = UIColor.background
        addNoteButton.addTarget(self, action: #selector(presentNewNoteVC), for: .touchUpInside)
        addNoteButton.layer.cornerRadius = 8
        addNoteButton.dropShadow()
        addNoteButton.layer.shouldRasterize = false
        
        self.view.bringSubviewToFront(addNoteButton)
       
        navigationItem.title = SectionTitle.todo.rawValue
        
        taskCountLabel = UILabel()
        taskCountLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        taskCountLabel.numberOfLines = 1
        taskCountLabel.text = "0 notes"
        taskCountLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        taskCountLabel.textColor = .lightGray
        
        let counterItem = UIBarButtonItem(customView: taskCountLabel)
                
        navigationItem.leftBarButtonItem = counterItem
        
        
//        navigation bar appearance
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if traitCollection.userInterfaceStyle == .light {
            
            self.navigationController?.navigationBar.overrideUserInterfaceStyle = .light
             
            appearance.backgroundColor = UIColor.white
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        } else {
            
            self.navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
             
            appearance.backgroundColor = UIColor.black
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        }
        
        appearance.shadowColor = .clear
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance

//        let menuButtonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(didTappedMenuButtonItem))
//        self.navigationItem.leftBarButtonItem = menuButtonItem
        
//        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: BoardsTableViewController())
//        // UISideMenuNavigationController is a subclass of UINavigationController, so do any additional configuration
//        // of it here like setting its viewControllers. If you're using storyboards, you'll want to do something like:
//        // let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
//        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
//        SideMenuManager.default.menuFadeStatusBar = false
//        SideMenuManager.default.menuShadowColor = UIColor.clear
        
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
    
        if traitCollection.userInterfaceStyle == .light {
            return .darkContent
        } else {
            return .lightContent
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.kanbanView.reload(data: Model.shared.getData())
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstRun {
            self.kanbanView.scrollToSectionWithIndex(1, animated: false)
            isFirstRun = false
        }
    }

    @objc func didTappedMenuButtonItem(){
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func presentNewNoteVC(){
        
        let newNoteVC = NewNoteViewController()
        let lastIndex = kanbanView.getLastIndexOfToDoSection()
        newNoteVC.mode = .create(lastIndex)
        let navigationVC = UINavigationController(rootViewController: newNoteVC)
        navigationVC.modalPresentationStyle = .fullScreen
        self.present(navigationVC, animated: true, completion: nil)
        
    }
    
}

extension MainViewController: KanbanViewDelegate {
   
    func kanbanView(_ kanbanView: KanbanView, didSelectItem item: KanbanItem, at indexPath: IndexPath) {
        
        let newNoteVC = NewNoteViewController()
        newNoteVC.mode = .edit(item as! Note)
        let navigationVC = UINavigationController(rootViewController: newNoteVC)
        navigationVC.modalPresentationStyle = .fullScreen
        
        self.present(navigationVC, animated: true, completion: nil)
        
    }
    
    func kanbanView(_ kanbanView: KanbanView, didScrollToSectionWithIndex index: Int) {
        
        let taskCount = kanbanView.data[index].count
        
        var taskCountText = ""
        
        switch(taskCount){
        case 0: taskCountText = "No tasks"
        case 1: taskCountText = "1 task"
        default: taskCountText = "\(taskCount) tasks"
        }
        
        taskCountLabel.text = taskCountText
        
        switch index {
        case 0: navigationItem.title = SectionTitle.todo.rawValue
        case 1: navigationItem.title = SectionTitle.progress.rawValue
        case 2: navigationItem.title = SectionTitle.done.rawValue
        default: break
        }
        
    }
    
    func kanbanView(_ kanbanView: KanbanView, didChangeOrderOfItems data: [[KanbanItem]]) {
        Model.shared.saveItemsOrder(data as! [[Note]])
    }
    
    func kanbanView(_ kanbanView: KanbanView, didMovedNoteToDifferentSection note: KanbanItem, sectionIndex: Int) {
        Model.shared.noteDidMovedToDifferentSection(note: note as! Note)
    }
    
    func kanbanView(_ kanbanView: KanbanView, configureCell cell: UICollectionViewCell, with item: KanbanItem, at indexPath: IndexPath) {
        
        guard let note = item as? Note, let cell = cell as? NotesCollectionViewCell else { return }
    
        cell.textLabel.text = note.text
        
        if indexPath.section == 1 && indexPath.item == 0 {
            cell.textLabel.textAlignment = .center
            cell.textLabel.textColor = .black
        } else if indexPath.section == 2 {
            cell.textLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            cell.textLabel.textAlignment = .left
        } else {
            cell.textLabel.textAlignment = .left
            cell.textLabel.textColor = .black
        }
        

        cell.containerView.backgroundColor = UIColor(hex: note.color)

        
    }
    
}
 
