//
//  ColorPickerView.swift
//  KNBN
//
//  Created by Robert Kim on 19/1/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import UIKit

protocol ColorPickerViewDelegate: AnyObject {
    func didPickColor(withHex hex: String)
}

class ColorPickerView: UIView {

    var colors: [String]
    
    weak var delegate: ColorPickerViewDelegate?
    
    init(colors: [String]) {
        self.colors = colors
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO XIB INIT FOR COLORPICKERVIEW")
    }
    
    func setup(){
        
        let stackView = UIStackView()
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(self)
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        for (index, color) in colors.enumerated() {
            
            let button = UIButton()
            button.backgroundColor = UIColor(hex: color)
            button.addTarget(self, action: #selector(colorButtonDidTapped), for: .touchUpInside)
            button.tag = index
            
            stackView.addArrangedSubview(button)
            
        }
        
    }
    
    @objc func colorButtonDidTapped(button: UIButton){
        delegate?.didPickColor(withHex: colors[button.tag])
    }

}
