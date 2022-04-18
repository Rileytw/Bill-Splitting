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
    let settleUpButton = UIButton()
    let width = UIScreen.main.bounds.width
    
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
        setSettleUpButton()
    }
    
    func setLabel() {
        personalFinalPaidLabel.frame = CGRect(x: 10, y: 10, width: width, height: 40)
//        personalFinalPaidLabel.text = "你的總支出為"
        personalFinalPaidLabel.font = personalFinalPaidLabel.font.withSize(24)
        addSubview(personalFinalPaidLabel)
    }
    
    func setAddExpenseButton() {
        addExpenseButton.frame = CGRect(x: 10, y: 60, width: width/2 - 40, height: 60)
        addExpenseButton.setTitle("新增支出", for: .normal)
        addExpenseButton.backgroundColor = .systemTeal
        addSubview(addExpenseButton)
    }
    
    func setSettleUpButton() {
        settleUpButton.frame = CGRect(x: 10 + width/2, y: 60, width: width/2 - 40, height: 60)
        settleUpButton.setTitle("前往結算", for: .normal)
        settleUpButton.backgroundColor = .systemOrange
        addSubview(settleUpButton)
    }
}
