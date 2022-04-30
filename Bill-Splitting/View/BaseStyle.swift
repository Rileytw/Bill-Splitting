//
//  BaseBackground.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/30.
//

import Foundation
import UIKit

class ElementsStyle {
     
    static func styleBackground(_ view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.4, 0.8]
        let darkBlueColor = UIColor.hexStringToUIColor(hex: "041C32").cgColor
//        272343
//        1D4D4F
//        let lightBlueColor = UIColor(red: 53/255, green: 115/255, blue: 118/255, alpha: 0.9).cgColor
        let lightBlueColor = UIColor.hexStringToUIColor(hex: "357376").cgColor
//        357376
        gradientLayer.colors = [darkBlueColor, lightBlueColor]
        view.layer.addSublayer(gradientLayer)
    }
    
    static func styleButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "E2C275").cgColor
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.greenWhite
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "E2C275")
//        32407B
//        29A19C
//        FFD36E
//        ECB365
    }
    
    static func styleSelectedButton(_ button: UIButton) {
        button.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 8
//        button.layer.shadowColor = UIColor(red: 111/255, green: 223/255, blue: 223/255, alpha: 0.9).cgColor
        button.layer.shadowColor = UIColor(red: 252/255, green: 217/255, blue: 0/255, alpha: 0.5).cgColor
//        rgb(236, 179, 101)
        button.layer.shadowPath = UIBezierPath(rect: button.bounds).cgPath
    }
    
    static func styleNotSelectedButton(_ button: UIButton) {
        button.layer.shadowOffset = CGSize.init(width: 0, height: 0)
        button.layer.shadowOpacity = 0
        button.layer.shadowRadius = 0
        button.layer.shadowColor = CGColor.init(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        button.layer.shadowPath = UIBezierPath(rect: button.bounds).cgPath
    }
    
    static func styleSpecificButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "29A19C").cgColor
        button.layer.cornerRadius = 20
        button.backgroundColor = UIColor(red: 227/255, green: 246/255, blue: 245/255, alpha: 0.5)
    }
}
