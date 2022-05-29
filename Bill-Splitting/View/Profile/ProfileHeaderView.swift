//
//  ProfileCollectionHeaderView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/2.
//

import UIKit

class ProfileHeaderView: UICollectionReusableView {
    
    static let identifier = "ProfileHeaderView"
    
    let label = UILabel()
    
    func configure() {
        backgroundColor = .clear
        addSubview(label)
        label.textColor = .greenWhite
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 8, y: 20, width: 100, height: 40)
    }
    
}
