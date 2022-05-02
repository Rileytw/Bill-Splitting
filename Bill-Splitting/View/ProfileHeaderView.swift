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
        backgroundColor = .greenWhite
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
}
