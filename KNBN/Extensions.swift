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
//
//extension Date {
//    var startOfDay: Date {
//        return Calendar.current.startOfDay(for: self)
//    }
//
//    var endOfDay: Date {
//        var components = DateComponents()
//        components.day = 1
//        components.second = -1
//        return Calendar.current.date(byAdding: components, to: startOfDay)!
//    }
//}

extension UIColor {
    convenience init(hex: String) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }


        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
           red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
           green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
           blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
           alpha: CGFloat(1.0)
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
