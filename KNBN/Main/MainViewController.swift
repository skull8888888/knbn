//
//  ViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/14/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var notesCollectionView: NotesCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        notesCollectionView = NotesCollectionView(frame: .zero)
        self.view.addSubview(notesCollectionView)
        notesCollectionView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.leading.top.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.leading.top.trailing.bottom.equalTo(self.view)
            }
        }
        notesCollectionView.delegate = self

        let addNoteButton = UIButton(frame: .zero)
        self.view.addSubview(addNoteButton)
        addNoteButton.snp.makeConstraints { (make) in
            
            make.leading.equalTo(self.view).offset(32)
            make.trailing.equalTo(self.view).offset(-32)
            make.height.equalTo(48)
            
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(8)
            } else {
                make.bottom.equalTo(self.view.snp.bottom).offset(8)
            }
        }
        
        addNoteButton.setTitle("NOTE", for: .normal)
        addNoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight(rawValue: 400))
        addNoteButton.setTitleColor(UIColor.subtitle, for: .normal)
        addNoteButton.backgroundColor = UIColor.background
        addNoteButton.addTarget(self, action: #selector(presentNewNoteVC), for: .touchUpInside)
        addNoteButton.layer.cornerRadius = 8
        
        self.view.bringSubviewToFront(addNoteButton)
       
        let fadeTextAnimation = CATransition()
        fadeTextAnimation.duration = 0.5
        fadeTextAnimation.type = CATransitionType.fade
        
        navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        navigationItem.title = "TO DO"
     
        hideNavigationBar()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.notesCollectionView.reloadData()
    }
    
    @objc func presentNewNoteVC(){
        let newNoteVC = NewNoteViewController()
        self.present(UINavigationController(rootViewController: newNoteVC), animated: true, completion: nil)
    }
    
}

extension MainViewController: NotesCollectionViewCellDelegate {
    
    func didScrollToSection(with index: Int) {
        
        switch index {
        case 0: navigationItem.title = "TO DO"
        case 1: navigationItem.title = "PROGRESS"
        case 2: navigationItem.title = "DONE"
        default: break
        }
        
    }
    
    func didSelectNote(_ note: Note){
        let newNoteVC = NewNoteViewController()
        newNoteVC.mode = .edit(note)
        self.present(UINavigationController(rootViewController: newNoteVC), animated: true, completion: nil)
    }
    
}
