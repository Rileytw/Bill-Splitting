//
//  ChartViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
    var creditLabel = UILabel()
    var debtLabel = UILabel()
    var dismissButton = UIButton()
    var creditChart = PieChart(frame: .zero)
    var debtChart = PieChart(frame: .zero)
    var memberExpense: [MemberExpense] = []
    var creditMember: [MemberExpense] = []
    var debtMember: [MemberExpense] = []
    var userData = [UserData]()
    var member = [UserData]()
    let height = UIScreen.main.bounds.height
    var blackList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        ElementsStyle.styleBackground(view)
        setCreditLabel()
        setCreditChart()
        setDebtLabel()
        setDebtChart()
        getMemberData()
        detectBlackListUser()
        detectCreditMember()
        detectDebtMember()
        setDismissButton()
    }
    
    func getMemberData() {
        for index in 0..<userData.count {
            member += userData.filter { $0.userId == memberExpense[index].userId }
        }
    }
    
    func detectCreditMember() {
        creditMember = memberExpense.filter { $0.allExpense > 0 }
        var creditUser = [UserData]()
        
        for index in 0..<creditMember.count {
            creditUser += member.filter { $0.userId == creditMember[index].userId}
        }

        for member in 0..<creditMember.count {
            creditChart.pieChartDataEntries.append( PieChartDataEntry(value: creditMember[member].allExpense, label: creditUser[member].userName, icon: nil, data: nil))
        }
    }
    
    func detectDebtMember() {
        debtMember = memberExpense.filter { $0.allExpense < 0 }
        var debtUser = [UserData]()
        
        for index in 0..<debtMember.count {
            debtUser += member.filter { $0.userId == debtMember[index].userId}
        }

        for member in 0..<debtMember.count {
            debtChart.pieChartDataEntries.append( PieChartDataEntry(value: abs(debtMember[member].allExpense), label: debtUser[member].userName, icon: nil, data: nil))
        }
    }
    
    func setCreditChart() {
        view.addSubview(creditChart)
        creditChart.translatesAutoresizingMaskIntoConstraints = false
        creditChart.topAnchor.constraint(equalTo: creditLabel.bottomAnchor, constant: 20).isActive = true
        creditChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        creditChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        creditChart.heightAnchor.constraint(equalToConstant: height/2 - 100).isActive = true
        
    }
    
    func setDebtChart() {
        view.addSubview(debtChart)
        debtChart.translatesAutoresizingMaskIntoConstraints = false
        debtChart.topAnchor.constraint(equalTo: debtLabel.bottomAnchor, constant: 20).isActive = true
        debtChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        debtChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        debtChart.heightAnchor.constraint(equalToConstant: height/2 - 100).isActive = true
        
    }
    
    func setCreditLabel() {
        view.addSubview(creditLabel)
        creditLabel.translatesAutoresizingMaskIntoConstraints = false
        creditLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        creditLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        creditLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        creditLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        creditLabel.text = "支出分佈"
        creditLabel.textColor = UIColor.greenWhite
        creditLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    func setDebtLabel() {
        view.addSubview(debtLabel)
        debtLabel.translatesAutoresizingMaskIntoConstraints = false
        debtLabel.topAnchor.constraint(equalTo: creditChart.bottomAnchor, constant: 20).isActive = true
        debtLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        debtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        debtLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        debtLabel.text = "欠款分佈"
        debtLabel.textColor = UIColor.greenWhite
        debtLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    func setDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.greenWhite
        dismissButton.addTarget(self, action: #selector(pressDismiss), for: .touchUpInside)
    }
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                                        userData: userData ?? [])
        userData = newUserData
        
        let newMemberData = UserManager.renameBlockedUser(blockList: blackList, userData: member)
        member = newMemberData
    }
}
