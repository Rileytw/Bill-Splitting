//
//  TexFieldView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit

class BasePickerViewInTextField: UIView {
    var textField = UITextField()
    let pickerView = UIPickerView()
    let width = UIScreen.main.bounds.width
    var icon = UIButton()
//    var icon = UIImageView()
    var pickerViewData: [String] = [""]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTextFieldOfPickerView()
        setIcon()
    }
    
    func setUpPickerView(data:[String]) {
        pickerViewData = data
    }
    
    func setTextFieldOfPickerView() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        textField.inputView = pickerView
//        textField.text = pickerViewData[0]
        textField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.selectedColor
        textField.textColor = UIColor.greenWhite
    }
    
    func setIcon() {
        icon.setBackgroundImage(UIImage(named: "arrowDown"), for: .normal)
        icon.tintColor = UIColor.hexStringToUIColor(hex: "E5DFDF")
        
        icon.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        icon.isUserInteractionEnabled = false
        
        textField.rightView = icon
        textField.rightViewMode = .always
    }
}
