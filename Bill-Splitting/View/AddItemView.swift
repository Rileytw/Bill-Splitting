//
//  AddItemView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/14.
//

import UIKit

class AddItemView: UIView {

    let createdTimeLabel = UILabel()
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
        createdTimeLabel.frame = CGRect(x: 20, y: 10, width: UIScreen.main.bounds.width/4, height: 60)
//        createdTimeLabel.text = "新增時間"
        addSubview(createdTimeLabel)
        
        itemName.frame = CGRect(x: 20, y: 30, width: UIScreen.main.bounds.width/3, height: 20)
//        itemName.text = "項目名稱"
        addSubview(itemName)
        
        priceLabel.frame = CGRect(x: 20, y: 100, width: UIScreen.main.bounds.width/3, height: 20)
//        priceLabel.text = "支出金額"
        addSubview(priceLabel)
        
        itemName.lineBreakMode = NSLineBreakMode.byWordWrapping
        itemName.numberOfLines = 0
    }
    
    func setTextField() {
        itemNameTextField.translatesAutoresizingMaskIntoConstraints = false
        itemNameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        itemNameTextField.frame = CGRect(x: UIScreen.main.bounds.width/3, y: 30, width: UIScreen.main.bounds.width/2 + 20, height: 40)
        addSubview(itemNameTextField)
        
        priceTextField.translatesAutoresizingMaskIntoConstraints = false
        priceTextField.borderStyle = UITextField.BorderStyle.roundedRect
        priceTextField.frame = CGRect(x: UIScreen.main.bounds.width/3, y: 100, width: UIScreen.main.bounds.width/2 + 20, height: 40)
        addSubview(priceTextField)
    }
}
