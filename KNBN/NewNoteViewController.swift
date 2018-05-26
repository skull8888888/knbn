//
//  CreateViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/22/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit
import RealmSwift

class Note: Object {
    dynamic var text: NSString = ""
    dynamic var angle: NSNumber = 0.0
    dynamic var color: NSString = ""
    dynamic var type: NSString = ""
    dynamic var index: NSNumber = 0
}

class NewNoteViewController: UIViewController, UITextViewDelegate {

    
    var textView: UITextView!
    var counterLabel: UILabel!
    var closeButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var saveButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    var textColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    var buttonFont = UIFont.systemFont(ofSize: 24, weight: 300)
    
    
    var screen = UIScreen.main.bounds
    
    var colors = ["81D4FA", "80CBC4", "C5E1A5", "FFF59D", "FFAB91", "E57373"]
    var realm: Realm!
    
    var lastNoteIndex: Int = 0
    var note: Note!
    var mode = ""
    
    var mainColorString: NSString!
    var mainColor: UIColor! {
        
        didSet{
            view.backgroundColor = mainColor
            navigationController?.navigationBar.barTintColor = mainColor
        }
        
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        realm = try! Realm()
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    
        counterLabel = UILabel(frame: CGRect(x:0,y:0,width:120, height:18))
        counterLabel.textAlignment = .center
        counterLabel.textColor = textColor
        counterLabel.font = buttonFont
        
        navigationController?.navigationBar.topItem?.titleView = counterLabel
        
        closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(add))
        deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(remove))
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
       
        closeButton.setTitleTextAttributes([ NSForegroundColorAttributeName: textColor, NSFontAttributeName:  buttonFont], for: .normal )
        addButton.setTitleTextAttributes([ NSForegroundColorAttributeName: textColor, NSFontAttributeName: buttonFont], for: .normal )
        deleteButton.setTitleTextAttributes([ NSForegroundColorAttributeName: textColor, NSFontAttributeName:  buttonFont], for: .normal )
        saveButton.setTitleTextAttributes([ NSForegroundColorAttributeName: textColor, NSFontAttributeName:  buttonFont], for: .normal )
        
        textView = UITextView(frame: CGRect(x: 0, y: 0, width: screen.width, height: 0))
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightRegular)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = self
        textView.textColor = textColor
//        textView.adjustsFontForContentSizeCategory = true
    
        if mode == "add" {
            navigationItem.leftBarButtonItem = closeButton
            navigationItem.rightBarButtonItem = addButton
            
            let random = Int(arc4random_uniform(6))
            
            mainColor = UIColor(hex: colors[random])
            mainColorString = colors[random] as NSString
        } else if mode == "edit" {
            navigationItem.leftBarButtonItem = saveButton
            navigationItem.rightBarButtonItem = deleteButton
            textView.text = note.text as String
        }
        
        view.addSubview(textView)
        
        counterLabel.text = "\(textView.text.characters.count)|150"
        textView.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        
    }
    
    
    func add(){
        
        let note = realm.objects(Note.self).filter("text = %@",textView.text).first
        
        if textView.text.characters.count > 0 && note == nil {
            
            var angle = (CGFloat(.pi / (175 - Double(arc4random_uniform(5)))))
            if Int(arc4random_uniform(2)) == 0{
                angle = angle * -1
            }
            
            let note = Note()
            note.text = textView.text! as NSString
            note.angle = NSNumber(value: Float(angle))
            note.color = mainColorString
            note.type = "ToDo" as NSString
            note.index = 99999
            
            try! realm.write {
                realm.add(note)
            }
            performSegue(withIdentifier: "unwind", sender: self)
        }
    }
    
    func save(){
        let note = realm.objects(Note.self).filter("text = %@", self.note.text).first
        
        try! realm.write{
            note?.text = textView.text as NSString
            note?.color = mainColorString
        }
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    func remove(){
        let note = realm.objects(Note.self).filter("text = %@", self.note.text).first!
        
        try! realm.write{
            realm.delete(note)
        }
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    func close(){
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        counterLabel.text = "\(textView.text.characters.count)|150"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(textView.text.characters.count >= 150 && range.length == 0) {
            return false
        }
        return true
    }
    
    func createColorPicker(y: CGFloat){
    
        let width = screen.width / CGFloat(colors.count)
       
        for (index, color) in colors.enumerated() {
        
            let button = UIButton(frame: CGRect(x: CGFloat(index) * width, y: y - 64 - width, width: width, height: width ))
            
            button.backgroundColor = UIColor(hex: color)
            button.addTarget(self, action: #selector(changeColor(button:)), for: .touchUpInside)
            button.tag = index
            
            view.addSubview(button)
        
        }
        
    }
    
    func changeColor(button: UIButton){
      
        UIView.animate(withDuration: 0.2, animations: {
            self.mainColor = button.backgroundColor!
            self.mainColorString = self.colors[button.tag] as NSString
        })
        
    }
    
    func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            textView.frame.size.height = screen.height - keyboardSize.height
            
            createColorPicker(y: textView.frame.maxY)
         
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }

}
