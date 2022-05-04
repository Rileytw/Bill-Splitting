//
//  BlockUserView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/4.
//

import UIKit

class BlockUserView: UIView {
    
    let blockUserButton = UIButton()
    let width = UIScreen.main.bounds.size.width
    let blockLabel = UILabel()
    let dismissButton = UIButton()
    
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

        blockUserButton.frame = CGRect(x: (width - 200)/2, y: 40, width: 200, height: 60)
        blockUserButton.setTitle(" 封鎖使用者", for: .normal)
        blockUserButton.setImage(UIImage(systemName: "person.crop.circle.badge.exclam.fill"), for: .normal)
        blockUserButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(blockUserButton)
        
        addSubview(blockUserButton)
    }
    
    func setBlockLabel() {
        blockLabel.frame = CGRect(x: (width - 250)/2, y: 120, width: 250, height: 60)
        blockLabel.text = "封鎖使用者後，將隱藏您已結清的共享群組"
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
}
