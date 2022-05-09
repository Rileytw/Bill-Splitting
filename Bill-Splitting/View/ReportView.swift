//
//  ReportView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/5.
//

import UIKit

class ReportView: UIView {
    
    let reportButton = UIButton()
    let width = UIScreen.main.bounds.size.width
    let reportLabel = UILabel()
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

        reportButton.frame = CGRect(x: (width - 100)/2, y: 40, width: 100, height: 40)
        reportButton.setTitle(" 檢舉", for: .normal)
        reportButton.setImage(UIImage(systemName: "megaphone.fill"), for: .normal)
        reportButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(reportButton)
        
        addSubview(reportButton)
    }
    
    func setBlockLabel() {
        reportLabel.frame = CGRect(x: (width - 250)/2, y: 100, width: 250, height: 80)
        reportLabel.text = "檢舉後該款項及群組資料會回報至開發者。"
        reportLabel.textColor = .greenWhite
        
        reportLabel.numberOfLines = 0
        
        addSubview(reportLabel)
    }
    
    func setDismissButton() {
        dismissButton.frame = CGRect(x: width - 40, y: 5, width: 40, height: 40)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
        addSubview(dismissButton)
    }
}

