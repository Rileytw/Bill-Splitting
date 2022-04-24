//
//  ChartViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
    var creditChart = PieChart(frame: .zero)
    var debtChart = PieChart(frame: .zero)
    var memberExpense: [MemberExpense] = []
    var creditMember: [MemberExpense] = []
    var debtMember: [MemberExpense] = []
    var userData = [UserData]()
    var member = [UserData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCreditChart()
        setDebtChart()
        getMemberData()
        detectCreditMember()
        detectDebtMember()
    }
    
    func setCreditChart() {
        view.addSubview(creditChart)
        creditChart.translatesAutoresizingMaskIntoConstraints = false
        creditChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        creditChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        creditChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        creditChart.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    func setDebtChart() {
        view.addSubview(debtChart)
        debtChart.translatesAutoresizingMaskIntoConstraints = false
        debtChart.topAnchor.constraint(equalTo: creditChart.bottomAnchor, constant: 60).isActive = true
        debtChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        debtChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        debtChart.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    func getMemberData() {
        for index in 0..<userData.count {
            member += userData.filter { $0.userId == memberExpense[index].userId }
        }
    }
    
    func detectCreditMember() {
        creditMember = memberExpense.filter { $0.allExpense > 0 }
        print("credit:\(creditMember)")
        
        var creditUser = [UserData]()
        
        for index in 0..<creditMember.count {
            creditUser += member.filter { $0.userId == creditMember[index].userId}
        }

        for member in 0..<creditMember.count {
            creditChart.pieChartDataEntries.append( PieChartDataEntry(value: creditMember[member].allExpense, label: creditUser[member].userName, icon: nil, data: nil))
        }
        
        print("====creditUSer:\(creditUser)")
    }
    
    func detectDebtMember() {
        debtMember = memberExpense.filter { $0.allExpense < 0 }
        print("debt:\(debtMember)")
        
        var debtUser = [UserData]()
        
        for index in 0..<debtMember.count {
            debtUser += member.filter { $0.userId == debtMember[index].userId}
        }

        for member in 0..<debtMember.count {
            debtChart.pieChartDataEntries.append( PieChartDataEntry(value: abs(debtMember[member].allExpense), label: debtUser[member].userName, icon: nil, data: nil))
        }
        
        print("====debtUser:\(debtUser)")
    }
    
}
