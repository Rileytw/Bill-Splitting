//
//  NoDAtaChartsView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/8.
//

import UIKit

class NoDataChartsView: UIView {
    
    let noDataLabel = UILabel()
    var confirmButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setNoDataLabel()
        setConfirmButton()
    }
    
    func setNoDataLabel() {
        addSubview(noDataLabel)
        noDataLabel.textColor = .greenWhite
        noDataLabel.text = "群組內支出及欠款已歸零，目前暫無圖表資料"
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40).isActive = true
        noDataLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        noDataLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        noDataLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        noDataLabel.numberOfLines = 2
    }
    
    func setConfirmButton() {
        addSubview(confirmButton)
        ElementsStyle.styleSpecificButton(confirmButton)
        confirmButton.setTitle("確認", for: .normal)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.topAnchor.constraint(equalTo: noDataLabel.bottomAnchor, constant: 40).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
