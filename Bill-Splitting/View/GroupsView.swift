//
//  GroupsView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupsView: UIView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setButton()
    }
    
    func setButton() {
        let allGroupsButton = UIButton()
        allGroupsButton.frame = CGRect(x: 20, y: 20, width: 100, height: 40)
        allGroupsButton.setTitle("所有群組", for: .normal)
        allGroupsButton.backgroundColor = .systemGray
        
        addSubview(allGroupsButton)
    }
}
