//
//  ReportView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/5.
//

import UIKit

class ReportView: UIView {
    
    let reportButton = UIButton()
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
        addSubview(reportButton)
        reportButton.translatesAutoresizingMaskIntoConstraints = false
        reportButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        reportButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        reportButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        reportButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        reportButton.setTitle(" 檢舉", for: .normal)
        reportButton.setImage(UIImage(systemName: "megaphone.fill"), for: .normal)
        reportButton.tintColor = .greenWhite
        ElementsStyle.styleSpecificButton(reportButton)
    }
    
    func setBlockLabel() {
        addSubview(reportLabel)
        reportLabel.translatesAutoresizingMaskIntoConstraints = false
        reportLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 100).isActive = true
        reportLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        reportLabel.widthAnchor.constraint(equalToConstant: 280).isActive = true
        reportLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        reportLabel.text = "檢舉後該款項及群組資料會回報至開發者。"
        reportLabel.textColor = .greenWhite
        reportLabel.numberOfLines = 0
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
