//
//  EditingView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/7.
//

import UIKit

class EditingView: UIView {
    
    let completeButton = UIButton()
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
        addSubview(completeButton)
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 200).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        completeButton.setTitle(buttonTitle, for: .normal)
        completeButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(completeButton)
    }
    
    func setBlockLabel() {
        addSubview(blockLabel)
        blockLabel.translatesAutoresizingMaskIntoConstraints = false
        blockLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        blockLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        blockLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        blockLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        content = "新名稱"
        blockLabel.text = content
        blockLabel.textColor = .greenWhite
        
        blockLabel.numberOfLines = 0
    }
    
    func setDismissButton() {
        addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
    }
    
    func setTextField() {
        addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        textField.leadingAnchor.constraint(equalTo: blockLabel.trailingAnchor, constant: 0).isActive = true
        textField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        textField.placeholder = "輸入新名稱"
        ElementsStyle.styleTextField(textField)
    }
}
