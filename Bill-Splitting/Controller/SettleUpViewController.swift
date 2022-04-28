//
//  SettleUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/16.
//

import UIKit

class SettleUpViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let currentUserName = AccountManager.shared.currentUser.currentUserId // Use id temporary
    var groupData: GroupData?
    var memberExpense: [MemberExpense] = []
    var userData: [UserData] = []
    var expense: Double?
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "結算群組帳務"
        setTableView()
        removeCreatorData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: SettleUpTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SettleUpTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
    }
    
    func removeCreatorData() {
        if groupData?.creator == currentUserId {
            memberExpense = memberExpense.filter { $0.userId != currentUserId }
        }
    }
}

extension SettleUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupData?.creator == currentUserId {
            return memberExpense.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: SettleUpTableViewCell.self),
            for: indexPath
        )
        
        guard let settleUpCell = cell as? SettleUpTableViewCell,
              let expense = expense
        else { return cell }
        let memberExpense = memberExpense[indexPath.row]
        let memberData = userData.filter { $0.userId == memberExpense.userId }
        
        if groupData?.creator == currentUserId {
            if memberExpense.allExpense > 0 {
                settleUpCell.price.text = " $ \(memberExpense.allExpense)"
                settleUpCell.payerName.text = "\(currentUserName)"
                settleUpCell.creditorName.text = "\(memberData[0].userName)"
                
            } else {
                settleUpCell.price.text = " $ \(abs(memberExpense.allExpense))"
                settleUpCell.creditorName.text = "\(currentUserName)"
                settleUpCell.payerName.text = "\(memberData[0].userName)"
            }
        } else {
            if memberExpense.allExpense < 0 {
                settleUpCell.creditorName.text = "\(currentUserName)"
                settleUpCell.payerName.text = "\(memberData[0].userName)"
                settleUpCell.price.text = " $ \(expense)"
            } else {
                settleUpCell.price.text = " $ \(abs(expense))"
                settleUpCell.payerName.text = "\(currentUserName)"
                settleUpCell.creditorName.text = "\(memberData[0].userName)"
            }
        }
        
        return settleUpCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let specificSettleUpViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SpecificSettleIUpViewController.self))
                as? SpecificSettleIUpViewController else { return }
        
        let memberExpense = memberExpense[indexPath.row]
        let memberData = userData.filter { $0.userId == memberExpense.userId }
        let userExpense = self.memberExpense.filter { $0.userId == currentUserId}
        specificSettleUpViewController.userData = memberData[0]
        specificSettleUpViewController.memberExpense = memberExpense
        specificSettleUpViewController.groupId = groupData?.groupId
        specificSettleUpViewController.groupData = groupData
        specificSettleUpViewController.userExpense = userExpense
        self.show(specificSettleUpViewController, sender: nil)
    }
}
