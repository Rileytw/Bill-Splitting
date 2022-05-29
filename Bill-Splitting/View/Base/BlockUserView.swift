//
//  BlockUserView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/4.
//

import UIKit

class BlockUserView: UIView {
    
    let blockUserButton = UIButton()
    let blockLabel = UILabel()
    let dismissButton = UIButton()
    var buttonTitle: String?
    var content: String?
    
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
    }
    
    func setBlockButton() {
        addSubview(blockUserButton)
        blockUserButton.translatesAutoresizingMaskIntoConstraints = false
        blockUserButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        blockUserButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        blockUserButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        blockUserButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        blockUserButton.setTitle(buttonTitle, for: .normal)
        blockUserButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(blockUserButton)
    }
    
    func setBlockLabel() {
        addSubview(blockLabel)
        blockLabel.translatesAutoresizingMaskIntoConstraints = false
        blockLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        blockLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        blockLabel.widthAnchor.constraint(equalToConstant: 280).isActive = true
        blockLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
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
}
