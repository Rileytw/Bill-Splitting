//
//  GroupDetailView.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupDetailView: UIView {

    let personalFinalPaidLabel = UILabel()
    let addExpenseButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        setLabel()
        setAddExpenseButton()
    }
    
    func setLabel() {
        personalFinalPaidLabel.frame = CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width, height: 40)
//        personalFinalPaidLabel.text = "你的總支出為"
        personalFinalPaidLabel.font = personalFinalPaidLabel.font.withSize(24)
        addSubview(personalFinalPaidLabel)
    }
    
    func setAddExpenseButton() {
        addExpenseButton.frame = CGRect(x: 10, y: 60, width: 100, height: 60)
        addExpenseButton.setTitle("新增支出", for: .normal)
        addExpenseButton.backgroundColor = .systemGray
        addSubview(addExpenseButton)
    }
}
