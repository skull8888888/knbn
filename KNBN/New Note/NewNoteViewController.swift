//
//  CreateViewController.swift
//  KNBN
//
//  Created by Robert Kim on 5/22/17.
//  Copyright © 2017 Octopus. All rights reserved.
//

import UIKit
import RealmSwift

class NewNoteViewController: UIViewController {

    var colorPickerMasterView: ColorPickerMasterView!
    var textView: UITextView!
    var counterLabel: UILabel!
    
    enum Mode {
        case create(Int)
        case edit(Note)
    }
    
    var mode: Mode = .create(0)
    
    var mainColorString: String! {
        didSet {
            mainColor = UIColor(hex: mainColorString)
        }
    }
    
    var mainColor: UIColor! {
        didSet{
            view.backgroundColor = mainColor
        }
    }
    
    var colors: [[String]] = [Standard.palette1, Standard.palette2, Standard.palette3]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    
        counterLabel = UILabel(frame: CGRect(x:0,y:0,width:120, height:18))
        counterLabel.textAlignment = .center
        counterLabel.textColor = UIColor.tint
        counterLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 24, weight: .heavy)
        
        
        navigationController?.navigationBar.topItem?.titleView = counterLabel
        
        let cancelButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(cancelButtonDidTapped))
        let doneButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(doneButtonDidTapped))
    
        self.textView = UITextView()
        self.view.addSubview(textView)
        
        self.colorPickerMasterView = ColorPickerMasterView(colors: colors)
        colorPickerMasterView.delegate = self
        self.view.addSubview(colorPickerMasterView)
        
        textView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.leading.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
            } else {
                make.leading.top.trailing.equalTo(self.view)
            }
            make.bottom.equalTo(colorPickerMasterView.snp.top).offset(0)
        }
        
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = self
        textView.textColor = .subtitle
        textView.becomeFirstResponder()
        
        colorPickerMasterView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(64)
        }
        
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = doneButton
        
        switch mode {
        case .create:

            let random1 = Int(arc4random_uniform(3))
            let random2 = Int(arc4random_uniform(6))
            
            mainColorString = colors[random1][random2]
            
            cancelButton.title = "Cancel"
            doneButton.title = "Done"
            
        case .edit(let note):
            
            textView.text = note.text
            mainColorString = note.color
            
            cancelButton.title = "Save"
            doneButton.title = "Delete"
        }
     
        updateCounterLabelText()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    
    @objc func doneButtonDidTapped(){
        
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
    
        switch mode {
        case .create(let lastIndex):
            
            let note = Note()
            note.id = UUID().uuidString
            note.text = self.textView.text
            note.angle = generateRandomAngle()
            note.color = self.mainColorString
            note.index = lastIndex
            note.section = 0
            note.createdDate = Date()
            note.editedDate = Date()
            
            Model.shared.add(note)
            
        case .edit(let note):
            note.editedDate = Date()
            Model.shared.delete(note)
        }
        
        self.dismiss(animated: true, completion: nil)
       
    }
    
    private func generateRandomAngle() -> CGFloat {
        
        var angle = (CGFloat(.pi / (175 - Double(arc4random_uniform(5)))))
        
        if Int(arc4random_uniform(2)) == 0{
            angle = angle * -1
        }
        
        return angle
    }
    
    @objc func cancelButtonDidTapped(){
        switch mode {
        case .create:
            self.dismiss(animated: true, completion: nil)
        case .edit(let note):
            Model.shared.save(id: note.id, text: self.textView.text, colorHEX: self.mainColorString)
            self.dismiss(animated: true, completion: nil)
        }
                                                        
    }
   
    func changeBackgroundColor(withHex hex: String){
      
        UIView.animate(withDuration: 0.2, animations: {
            self.mainColorString = hex
        })
        
    }
    
    @objc func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            colorPickerMasterView.snp.makeConstraints { (make) in
                make.bottom.equalTo(self.view.snp.bottom).offset(-keyboardSize.height)
            }
        }
        
    }
    
    func updateCounterLabelText(){
        var countString = "\(self.textView.text.count)"
        let hidingRange = 0..<(3 - countString.count)
        
        switch countString.count {
        case 1: countString = "00\(countString)"
        case 2: countString = "0\(countString)"
        default: break
        }
        
        let finalText = "\(countString)|150"
        let mutableString = NSMutableAttributedString(string: finalText)
        
        mutableString.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(hidingRange))
        
        counterLabel.attributedText = mutableString
    }

}

extension NewNoteViewController: ColorPickerViewDelegate {
    
    func didPickColor(withHex hex: String) {
        changeBackgroundColor(withHex: hex)
    }
    
}

extension NewNoteViewController: UITextViewDelegate {
    
    
    func textViewDidChange(_ textView: UITextView) {
        updateCounterLabelText()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(textView.text.count >= 150 && range.length == 0) {
            return false
        }
        return true
    }
    
    
}
