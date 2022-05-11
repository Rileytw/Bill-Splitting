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
        icon.setImage(UIImage(systemName: "arrowtriangle.down.square"), for: .normal)
        icon.tintColor = UIColor.hexStringToUIColor(hex: "E5DFDF")
        
        icon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        icon.contentMode = .scaleAspectFit
        icon.isUserInteractionEnabled = false
        let padding: CGFloat = 2

        let rightView = UIView(frame: CGRect(
            x: 0, y: 0,
            width: icon.frame.width + padding,
            height: icon.frame.height))
        rightView.addSubview(icon)
        textField.rightView = rightView
        textField.rightViewMode = .always
    }
}
