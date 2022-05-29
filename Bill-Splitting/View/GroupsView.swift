//
//  GroupsView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupsView: UIView {
        
    let allGroupsButton = UIButton()
    let multipleGroupsButton = UIButton()
    let personalGroupsButton = UIButton()
    
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
        allGroupsButton.frame = CGRect(x: 20, y: 20, width: 100, height: 40)
        allGroupsButton.setTitle("所有群組", for: .normal)
        allGroupsButton.backgroundColor = .systemBlue
        
        addSubview(allGroupsButton)
        
        multipleGroupsButton.frame = CGRect(x: 140, y: 20, width: 100, height: 40)
        multipleGroupsButton.setTitle("多人支付", for: .normal)
        multipleGroupsButton.backgroundColor = .systemGreen
        
        addSubview(multipleGroupsButton)
        
        personalGroupsButton.frame = CGRect(x: 260, y: 20, width: 100, height: 40)
        personalGroupsButton.setTitle("個人預付", for: .normal)
        personalGroupsButton.backgroundColor = .systemYellow
        
        addSubview(personalGroupsButton)
    }
}
