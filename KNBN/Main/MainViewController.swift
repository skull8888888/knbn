//
//  ViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/14/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    enum SectionTitle: String {
        case todo = "To Do"
        case progress = "Progress"
        case done = "Done Today"
    }
    
    var kanbanView: KanbanView!
    
    var isFirstRun = true;
    
    var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if traitCollection.userInterfaceStyle == .light {
            self.view.backgroundColor = .white
        } else {
            self.view.backgroundColor = .black
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
        
        countLabel = UILabel()
        countLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        countLabel.numberOfLines = 1
        countLabel.text = "0 notes"
        countLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        countLabel.textColor = .lightGray
        
        let counterItem = UIBarButtonItem(customView: countLabel)
                
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
        
        if kanbanView.currentSection == 0 {
            updateCountLabelText(count: kanbanView.data[0].count)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFirstRun {
            self.kanbanView.scrollToSectionWithIndex(1, animated: false)
            isFirstRun = false
        }
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

extension MainViewController {
    
    func updateCountLabelText(count: Int){
        
        var countText = ""
        
        switch(count){
        case 0: countText = "No tasks"
        case 1: countText = "1 task"
        default: countText = "\(count) tasks"
        }
        
        countLabel.text = countText
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
        
        let count = kanbanView.data[index].count
        
        updateCountLabelText(count: count)
        
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
        
        let count = kanbanView.data[sectionIndex].count
        updateCountLabelText(count: count)
        
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
 
