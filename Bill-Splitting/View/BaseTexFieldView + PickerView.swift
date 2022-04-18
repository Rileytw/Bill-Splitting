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
        textField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 60))
        textField.inputView = pickerView
        textField.text = pickerViewData[0]
        textField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        textField.textAlignment = .center
        addSubview(textField)
    }
    
    func setIcon() {
        icon.setImage(UIImage(systemName: "arrowtriangle.down.square"), for: .normal)
        addSubview(icon)
        icon.frame = CGRect(x: width - 80, y: -20, width: 100, height: 100)
        icon.tintColor = .systemGray
    }
}
