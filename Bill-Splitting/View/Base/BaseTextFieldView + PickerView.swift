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
    
    func setUpPickerView(data: [String]) {
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
        textField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        textField.textAlignment = .center
        textField.backgroundColor = UIColor.selectedColor
        textField.textColor = UIColor.greenWhite
    }
    
    func setIcon() {
        icon.setImage(UIImage(systemName: "arrowtriangle.down.square"), for: .normal)
        icon.isUserInteractionEnabled = false
        addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        icon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        icon.tintColor = UIColor.greenWhite
    }
}
