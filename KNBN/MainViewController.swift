//
//  ViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/14/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, BoardCollectionViewCellDelegate {

    var taskButton: UIButton!

    var scrollView: UIScrollView!
    var gradientLayer: CAGradientLayer!
    
    var boardCollectionView: BoardCollectionView!
    
    var selectedNote: Note!
    
    var screen = UIScreen.main.bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screen.width, height: screen.height))
        view.addSubview(scrollView)
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        boardCollectionView = BoardCollectionView(frame:CGRect(x: 0, y: 0, width: screen.width * 3, height: screen.height))
        boardCollectionView.delegate = self

        taskButton = UIButton(frame: CGRect(x: 16, y: screen.height - 50, width: screen.width - 32, height: 50))
        taskButton.setTitle("Task", for: .normal)
        taskButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: 400)
        taskButton.setTitleColor(UIColor(hex:"424242"), for: .normal)
        taskButton.topRoundedCorners()
        taskButton.backgroundColor = UIColor(hex: "eeeeee")
        taskButton.addTarget(self, action: #selector(toNewNote), for: .touchUpInside)
        
        scrollView.contentSize = boardCollectionView.frame.size
        scrollView.addSubview(boardCollectionView)
        scrollView.isPagingEnabled = true
        
        view.addSubview(scrollView)
        view.addSubview(taskButton)
        view.bringSubview(toFront: taskButton)
        
        scrollTo(point: CGPoint(x: screen.width, y: 0))
    }
    
    func didSelectNote(_ note: Note){
        selectedNote = note
        performSegue(withIdentifier: "toNewNote", sender: self)
    }
    

    func scrollTo(point: CGPoint) {
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentOffset = point
        })
    }
    
    func toNewNote(){
        performSegue(withIdentifier: "toNewNote", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNewNote" {
            
            let destinationNav = segue.destination as! UINavigationController
            let destinationVC = (destinationNav.viewControllers[0] as! NewNoteViewController)
            
            if selectedNote != nil {
                destinationVC.mode = "edit"
                destinationVC.note = selectedNote
                destinationVC.mainColorString = selectedNote.color
                destinationVC.mainColor = UIColor(hex: selectedNote.color as String)
                selectedNote = nil
            } else {
                destinationVC.mode = "add"
            }
            
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue){
        boardCollectionView.reloadData()
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UIView {
    func topRoundedCorners(){
        let maskPAth1 = UIBezierPath(roundedRect: self.bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii:CGSize(width: 8, height: 8 ))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = self.bounds
        maskLayer1.path = maskPAth1.cgPath
        self.layer.mask = maskLayer1
        
    }
}

