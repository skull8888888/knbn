//
//  Extensions.swift
//  KNBN
//
//  Created by Robert Kim on 17/1/2019.
//  Copyright © 2019 Octopus. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static var background: UIColor {
        return #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
    }
    
    static var tint: UIColor {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    static var subtitle: UIColor {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
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
    
    func dropShadow(cornerRadius: CGFloat = 8, shadowRadius: CGFloat = 2.0, y: CGFloat = 2, opacity: Float = 0.2) {
        
        
//        self.layer.shouldRasterize = true
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0.0, height: y)
        self.layer.shadowRadius = shadowRadius
        
//        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
//        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
        
    }
}

extension UIViewController {
    
    func hideNavigationBar(){
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
}
