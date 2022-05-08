//
//  NoDataView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/7.
//

import UIKit

class NoDataView: UIView {
    
    let noDataLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setNoDataLabel()
    }
    
    func setNoDataLabel() {
        addSubview(noDataLabel)
        noDataLabel.textColor = .greenWhite
        
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        noDataLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        noDataLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        noDataLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        noDataLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        noDataLabel.isHidden = true
    }
}
