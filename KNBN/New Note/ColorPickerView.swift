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
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)

        
        stackView.spacing = 2
        
        for (index, color) in colors.enumerated() {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            button.backgroundColor = UIColor(hex: color)
            button.layer.cornerRadius = 25
            button.layer.borderWidth = 3
            button.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(colorButtonDidTapped), for: .touchUpInside)
            button.tag = index
            
            stackView.addArrangedSubview(button)
            
        }
        
    }
    
    @objc func colorButtonDidTapped(button: UIButton){
        delegate?.didPickColor(withHex: colors[button.tag])
    }

}
