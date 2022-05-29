//
//  ChartViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Charts
import SwiftUI

class ChartViewController: UIViewController {
    
    // MARK: - Property
    var creditLabel = UILabel()
    var debtLabel = UILabel()
    var dismissButton = UIButton()
    var mask = UIView()
    var creditChart = PieChart(frame: .zero)
    var debtChart = PieChart(frame: .zero)
    var noDataChartsView = NoDataChartsView(frame: .zero)
    var noDataViewBottom: NSLayoutConstraint?
    
    var group: GroupData?
    var creditMember: [MemberExpense] = []
    var debtMember: [MemberExpense] = []
    var member = [UserData]()
    
    // MARK: - Lifecycle
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
    
    // MARK: - Method
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
    
    @objc func pressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func detectBlockListUser() {
        guard let blockList = UserManager.shared.currentUser?.blackList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList, userData: group?.memberData ?? [])
        group?.memberData = newUserData
        
        let newMemberData = UserManager.renameBlockedUser(blockList: blockList, userData: member)
        member = newMemberData
    }
    
    func revealBlockView() {
        mask.backgroundColor = .maskBackgroundColor
        view.stickSubView(mask)
        
        setNoDataView()
        noDataViewBottom?.constant = -200
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        
        noDataChartsView.confirmButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    private func setNoDataView() {
        noDataChartsView.removeFromSuperview()
        view.addSubview(noDataChartsView)
        noDataChartsView.translatesAutoresizingMaskIntoConstraints = false
        noDataChartsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataChartsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        noDataChartsView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        noDataViewBottom = noDataChartsView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        noDataViewBottom?.isActive = true
        noDataChartsView.backgroundColor = .darkBlueColor
        
        view.layoutIfNeeded()
    }
    
    @objc func pressDismissButton() {
        noDataViewBottom?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        mask.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
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
}
