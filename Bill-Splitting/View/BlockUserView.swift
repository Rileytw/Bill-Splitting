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

        blockUserButton.frame = CGRect(x: (width - 180)/2, y: 40, width: 180, height: 40)
        blockUserButton.setTitle(buttonTitle, for: .normal)
        blockUserButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(blockUserButton)
        
        addSubview(blockUserButton)
    }
    
    func setBlockLabel() {
        blockLabel.frame = CGRect(x: (width - 280)/2, y: 100, width: 280, height: 80)
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
}
