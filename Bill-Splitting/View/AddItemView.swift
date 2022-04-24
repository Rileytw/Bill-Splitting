//
//  AddItemView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemView: UIView {

    let itemName = UILabel()
    let itemNameTextField = UITextField()
    let priceLabel = UILabel()
    let priceTextField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setLabel()
        setTextField()
    }
    
    func setLabel() {
        addSubview(itemName)
        itemName.translatesAutoresizingMaskIntoConstraints = false
        itemName.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        itemName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        itemName.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/3).isActive = true
        itemName.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.topAnchor.constraint(equalTo: itemName.bottomAnchor, constant: 40).isActive = true
        priceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        priceLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/3).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        itemName.lineBreakMode = NSLineBreakMode.byWordWrapping
        itemName.numberOfLines = 0
    }
    
    func setTextField() {
        addSubview(itemNameTextField)
        itemNameTextField.translatesAutoresizingMaskIntoConstraints = false
        itemNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        itemNameTextField.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        itemNameTextField.leadingAnchor.constraint(equalTo: itemName.trailingAnchor, constant: 10).isActive = true
        itemNameTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2 + 20).isActive = true
        itemNameTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        addSubview(priceTextField)
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.borderStyle = UITextField.BorderStyle.roundedRect
        priceTextField.topAnchor.constraint(equalTo: itemNameTextField.bottomAnchor, constant: 10).isActive = true
        priceTextField.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 10).isActive = true
        priceTextField.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2 + 20).isActive = true
        priceTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
