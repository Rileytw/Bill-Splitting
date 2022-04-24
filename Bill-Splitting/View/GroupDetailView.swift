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
    let chartButton = UIButton()
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
        setChartButton()
        setSettleUpButton()
    }
    
    func setLabel() {
        personalFinalPaidLabel.frame = CGRect(x: 10, y: 10, width: width, height: 40)
        personalFinalPaidLabel.font = personalFinalPaidLabel.font.withSize(24)
        addSubview(personalFinalPaidLabel)
    }
    
    func setAddExpenseButton() {
        addExpenseButton.frame = CGRect(x: 0, y: 60, width: width/3, height: 40)
        addExpenseButton.setTitle("新增支出", for: .normal)
        addExpenseButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addExpenseButton.setTitleColor(.systemTeal, for: .normal)
        addExpenseButton.tintColor = .systemTeal
        addSubview(addExpenseButton)
    }
    
    func setChartButton() {
        chartButton.frame = CGRect(x: width/3, y: 60, width: width/3, height: 40)
        chartButton.setTitle("查看圖表", for: .normal)
        chartButton.setImage(UIImage(systemName: "chart.pie"), for: .normal)
        chartButton.setTitleColor(.systemYellow, for: .normal)
        chartButton.tintColor = .systemYellow
        addSubview(chartButton)
    }
    
    func setSettleUpButton() {
        settleUpButton.frame = CGRect(x: (width/3) * 2, y: 60, width: width/3, height: 40)
        settleUpButton.setTitle("前往結算", for: .normal)
        settleUpButton.setImage(UIImage(systemName: "dollarsign.circle"), for: .normal)
        settleUpButton.tintColor = .systemOrange
        settleUpButton.setTitleColor(.systemOrange, for: .normal)
        addSubview(settleUpButton)
    }
}
