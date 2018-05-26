//
//  NewDeskViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/25/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit
import RealmSwift

class Desk: Object {
    dynamic var name = ""
    dynamic var link = ""
    dynamic var color = ""
}

class NewDeskViewController: UIViewController, UITextFieldDelegate {
    
    
    var colors = ["81D4FA", "80CBC4", "C5E1A5", "FFF59D", "FFAB91", "B39DDB"]
    var realm: Realm!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var linkTextField: UITextField!
    
    var lastNoteIndex: Int = 0
    
    var screen = UIScreen.main.bounds
    
    var mainColorString: NSString!
    var mainColor: UIColor! {
        
        didSet{
            view.backgroundColor = mainColor
            navigationController?.navigationBar.barTintColor = mainColor
        }
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        realm = try! Realm()
        
    
        mainColor = UIColor(hex: colors[0])
        
    
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)

        
        nameTextField.delegate = self
        nameTextField.becomeFirstResponder()
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        let addButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(create))
        
        closeButton.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor(hex:"424242"), NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: 300)], for: .normal )
        addButton.setTitleTextAttributes([ NSForegroundColorAttributeName: UIColor(hex:"424242"), NSFontAttributeName: UIFont.systemFont(ofSize: 22, weight: 300)], for: .normal )
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = addButton
        
        nameTextField.adjustsFontSizeToFitWidth = true
        linkTextField.adjustsFontSizeToFitWidth = true
        
    }

    func close(){
    
    }
    
    func create(){
        
    }
    
    func createColorPicker(y: CGFloat){
        
        let width = screen.width / CGFloat(colors.count)
        
        for (index, color) in colors.enumerated() {
            
            let button = UIButton(frame: CGRect(x: CGFloat(index) * width, y: y - width - 64, width: width, height: width ))
            
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
        
        print("keyboard show")
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            createColorPicker(y: screen.height - keyboardSize.height)
            
        } else {
            print("wrong")
        }
    }
    
}
