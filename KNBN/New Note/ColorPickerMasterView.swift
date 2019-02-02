//
//  ColorPickerMasterView.swift
//  KNBN
//
//  Created by Robert Kim on 19/1/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import UIKit

class ColorPickerMasterView: UIView {

    var scrollView: UIScrollView!
    
    var colors: [[String]]
    
    weak var delegate: ColorPickerViewDelegate?
    
    init(colors: [[String]]) {
        self.colors = colors
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NO XIB INIT FOR COLORPICKERMASTERVIEW")
    }
    
    func setup(){
       
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(self)
        }
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, colors) in colors.enumerated() {
            
            let colorPickerView = ColorPickerView(colors: colors)
            self.scrollView.addSubview(colorPickerView)                                                                                             
            colorPickerView.delegate = self.delegate
            colorPickerView.snp.makeConstraints { (make) in
                make.width.equalTo(scrollView.snp.width)
                make.height.equalTo(scrollView.snp.height)
                make.leading.equalTo(self.frame.width * CGFloat(index))
            }
        }
        
        self.scrollView.contentSize = CGSize(width: self.frame.width * CGFloat(colors.count), height: self.frame.height)
    }
}
