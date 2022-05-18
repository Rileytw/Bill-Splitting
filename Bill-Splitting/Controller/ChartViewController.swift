//
//  ChartViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Charts

class ChartViewController: UIViewController {
    
    var group: GroupData?
    var creditLabel = UILabel()
    var debtLabel = UILabel()
    var dismissButton = UIButton()
    var creditChart = PieChart(frame: .zero)
    var debtChart = PieChart(frame: .zero)
//    var memberExpense: [MemberExpense] = []
    var creditMember: [MemberExpense] = []
    var debtMember: [MemberExpense] = []
//    var userData = [UserData]()
    var member = [UserData]()
    var blockList = [String]()
    var noDataChartsView = NoDataChartsView()
    var mask = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        ElementsStyle.styleBackground(view)
        setCreditLabel()
        setCreditChart()
        setDebtLabel()
        setDebtChart()
        getMemberData()
        detectBlockListUser()
        detectCreditMember()
        detectDebtMember()
        setDismissButton()
        detectData()
    }
    
    func getMemberData() {
        let memberExpense = group?.memberExpense
        if let memberData = group?.memberData {
            for index in 0..<memberData.count {
                member += memberData.filter { $0.userId == memberExpense?[index].userId }
            }
        }
    }
    
    func detectCreditMember() {
        creditMember = group?.memberExpense?.filter { $0.allExpense > 0 } ?? []
        var creditUser = [UserData]()
        
        for index in 0..<creditMember.count {
            creditUser += member.filter { $0.userId == creditMember[index].userId}
        }

        for member in 0..<creditMember.count {
            creditChart.pieChartDataEntries.append(
                PieChartDataEntry(value: creditMember[member].allExpense,
                                  label: creditUser[member].userName,
                                  icon: nil,
                                  data: nil)
            )}
    }
    
    func detectDebtMember() {
        debtMember = group?.memberExpense?.filter { $0.allExpense < 0 } ?? []
        var debtUser = [UserData]()
        
        for index in 0..<debtMember.count {
            debtUser += member.filter { $0.userId == debtMember[index].userId}
        }

        for member in 0..<debtMember.count {
            debtChart.pieChartDataEntries.append(
                PieChartDataEntry(value: abs(debtMember[member].allExpense),
                                  label: debtUser[member].userName, icon: nil,
                                  data: nil)
            )}
    }
    
    func detectData() {
        if debtMember.isEmpty == true && creditMember.isEmpty == true {
            revealBlockView()
        }
    }
    
    func setCreditChart() {
        view.addSubview(creditChart)
        creditChart.translatesAutoresizingMaskIntoConstraints = false
        creditChart.topAnchor.constraint(equalTo: creditLabel.bottomAnchor, constant: 10).isActive = true
        creditChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        creditChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        creditChart.heightAnchor.constraint(equalToConstant: UIScreen.height/2 - 100).isActive = true
        
    }
    
    func setDebtChart() {
        view.addSubview(debtChart)
        debtChart.translatesAutoresizingMaskIntoConstraints = false
        debtChart.topAnchor.constraint(equalTo: debtLabel.bottomAnchor, constant: 10).isActive = true
        debtChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        debtChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        debtChart.heightAnchor.constraint(equalToConstant: UIScreen.height/2 - 100).isActive = true
        
    }
    
    func setCreditLabel() {
        view.addSubview(creditLabel)
        creditLabel.translatesAutoresizingMaskIntoConstraints = false
        creditLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
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
        debtLabel.topAnchor.constraint(equalTo: creditChart.bottomAnchor, constant: 10).isActive = true
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
    
    func detectBlockListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blockList, userData: group?.memberData ?? [])
        group?.memberData = newUserData
        
        let newMemberData = UserManager.renameBlockedUser(blockList: blockList, userData: member)
        member = newMemberData
    }
    
    func revealBlockView() {
        mask = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        mask.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(mask)
        
        noDataChartsView = NoDataChartsView(
            frame: CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 200))
        noDataChartsView.backgroundColor = .darkBlueColor
       
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.noDataChartsView.frame = CGRect(x: 0, y: UIScreen.height/2 - 100, width: UIScreen.width, height: 200)
        }, completion: nil)
        view.addSubview(noDataChartsView)

        noDataChartsView.confirmButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    @objc func pressDismissButton() {
        let subviewCount = self.view.subviews.count
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.subviews[subviewCount - 1].frame = CGRect(
                x: 0, y: UIScreen.height, width: UIScreen.width, height: UIScreen.height
            )}, completion: nil)
        mask.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }
}
