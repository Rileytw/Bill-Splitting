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
        let darkBlueColor = UIColor.hexStringToUIColor(hex: "031927").cgColor
        let lightBlueColor = UIColor.hexStringToUIColor(hex: "031927").cgColor
        gradientLayer.colors = [darkBlueColor, lightBlueColor]
        view.layer.addSublayer(gradientLayer)
    }
    
    static func styleButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "508AA8").cgColor
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.greenWhite
        button.setTitleColor(UIColor.styleBlue, for: .normal)
        button.backgroundColor = .selectedColor
    }
    
    static func styleSelectedButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "508AA8").cgColor
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.greenWhite, for: .normal)
        button.backgroundColor = .selectedColor
    }
    
    static func styleNotSelectedButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "508AA8").cgColor
        button.layer.cornerRadius = 10
        button.setTitleColor(UIColor.greenWhite, for: .normal)
        button.backgroundColor = .clear
    }
    
    static func styleSpecificButton(_ button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "5EB1BF").cgColor
        button.layer.cornerRadius = 18
        button.backgroundColor = UIColor(red: 227/255, green: 246/255, blue: 245/255, alpha: 0.5)
        button.tintColor = .greenWhite
        button.setTitleColor(.greenWhite, for: .normal)
    }
    
    static func styleTextField(_ textfield: UITextField) {        
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textfield.frame.height - 3, width: textfield.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.selectedColor.cgColor
        textfield.borderStyle = UITextField.BorderStyle.none
        textfield.textColor = .greenWhite
        textfield.layer.addSublayer(bottomLine)
        textfield.layer.masksToBounds = true
    }
    
    static func styleView(_ view: UIView) {
        view.backgroundColor =  UIColor(red: 29/255, green: 45/255, blue: 68/255, alpha: 0.8)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.hexStringToUIColor(hex: "3E5C76").cgColor
        view.layer.cornerRadius = 10
    }
    
    static func styleSearchBar(_ searchBar: UISearchBar) {
        searchBar.barTintColor = UIColor.hexStringToUIColor(hex: "A0B9BF")
        searchBar.searchTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        searchBar.tintColor = UIColor.hexStringToUIColor(hex: "E5DFDF")
        searchBar.searchTextField.textColor = .styleBlue
    }
    
    static func styleTextView(_ textView: UITextView) {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.selectedColor.cgColor
        textView.backgroundColor = .clear
        textView.textColor = UIColor.greenWhite
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
    }
}
