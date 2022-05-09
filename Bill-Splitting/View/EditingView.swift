//
//  EditingView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/7.
//

import UIKit

class EditingView: UIView {
    
    let completeButton = UIButton()
    let width = UIScreen.main.bounds.size.width
    let blockLabel = UILabel()
    let dismissButton = UIButton()
    var buttonTitle: String?
    var content: String?
    var textField = UITextField()
    var profileImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setBlockButton()
        setBlockLabel()
        setDismissButton()
        setTextField()
    }
    
    func setBlockButton() {

        completeButton.frame = CGRect(x: (width - 180)/2, y: 200, width: 180, height: 40)
        completeButton.setTitle(buttonTitle, for: .normal)
        completeButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(completeButton)
        
        addSubview(completeButton)
    }
    
    func setBlockLabel() {
        blockLabel.frame = CGRect(x: 40, y: 100, width: 80, height: 40)
        content = "新名稱"
        blockLabel.text = content
        blockLabel.textColor = .greenWhite
        
        blockLabel.numberOfLines = 0
        
        addSubview(blockLabel)
    }

    func setDismissButton() {
        dismissButton.frame = CGRect(x: width - 40, y: 5, width: 40, height: 40)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
        addSubview(dismissButton)
    }
    
    func setTextField() {
        textField.frame = CGRect(x: 140, y: 100, width: 200, height: 40)
        textField.placeholder = "輸入新名稱"
        ElementsStyle.styleTextField(textField)
        addSubview(textField)
    }
}
