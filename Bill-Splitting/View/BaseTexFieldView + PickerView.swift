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
        textField.topAnchor.constraint(equalTo:self.topAnchor , constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        textField.inputView = pickerView
        textField.text = pickerViewData[0]
        textField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        textField.textAlignment = .center
    }
    
    func setIcon() {
        icon.setImage(UIImage(systemName: "arrowtriangle.down.square"), for: .normal)
        addSubview(icon)
//        icon.frame = CGRect(x: width - 80, y: -20, width: 100, height: 100)
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        icon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 100).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 100).isActive = true
        icon.tintColor = .systemGray
    }
}
