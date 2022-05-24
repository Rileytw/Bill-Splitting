//
//  SettleUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/16.
//

import UIKit

class SettleUpViewController: UIViewController {
    
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var currentUserName = UserManager.shared.currentUser?.userName ?? ""
    var creator: UserData?
    var group: GroupData?
    var expense: Double?
//    var blockList = [String]()
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "結算群組帳務"
        ElementsStyle.styleBackground(view)
        checkLeaveMember()
        getCreatorData()
        detectBlockListUser()
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
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: SettleUpTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SettleUpTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
    }
    
    func removeCreatorData() {
        if let memberExpense = group?.memberExpense {
            if group?.creator == currentUserId {
                group?.memberExpense = memberExpense.filter { $0.userId != currentUserId }
            }
        }
    }
    
    func getCreatorData() {
        if let userData = group?.memberData {
            for member in userData where member.userId == group?.creator {
                creator = member
            }
        }
    }
    
    func detectBlockListUser() {
        let blockList = UserManager.shared.currentUser?.blackList
        guard let blockList = blockList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList,
                                                        userData: group?.memberData ?? [])
        group?.memberData = newUserData
        
        guard let creatorName = creator?.userName else { return }
        for user in blockList {
            if creator?.userId == user {
                creator?.userName = creatorName + "（已封鎖）"
            }
        }
    }
    
    func checkLeaveMember() {
        if let leaveMemberData = group?.leaveMemberData {
            if leaveMemberData.isEmpty == false {
                for index in 0..<leaveMemberData.count {
                    group?.leaveMemberData?[index].userName = leaveMemberData[index].userName + "（已離開群組）"
                }
                
                group?.memberData! += leaveMemberData
            }
        }
    }
}

extension SettleUpViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if group?.creator == currentUserId {
            return group?.memberExpense?.count ?? 0
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
        let memberExpense = group?.memberExpense?[indexPath.row]
        let memberData = group?.memberData?.filter { $0.userId == memberExpense?.userId }
        
        if group?.creator == currentUserId {
            if let revealExpense = memberExpense?.allExpense {
                if (memberExpense?.allExpense ?? 0) > 0 {
                    settleUpCell.price.text = " $ " + String(format: "%.2f", revealExpense)
                    settleUpCell.payerName.text = currentUserName
                    settleUpCell.creditorName.text = "\(memberData?[0].userName ?? "")"
                    
                } else {
                    settleUpCell.price.text = " $ " + String(format: "%.2f", abs(revealExpense))
                    settleUpCell.creditorName.text = currentUserName
                    settleUpCell.payerName.text = "\(memberData?[0].userName ?? "")"
                }
            }
        } else {
            if expense < 0 {
                settleUpCell.payerName.text = currentUserName
                settleUpCell.creditorName.text = "\(creator?.userName ?? "")"
                settleUpCell.price.text = " $ " + String(format: "%.2f", abs(expense))
            } else {
                settleUpCell.price.text = " $ " + String(format: "%.2f", expense)
                settleUpCell.creditorName.text = currentUserName
                settleUpCell.payerName.text = "\(creator?.userName ?? "")"
            }
        }
        
        return settleUpCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let specificSettleUpViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: SpecificSettleIUpViewController.self)
        ) as? SpecificSettleIUpViewController else { return }
        
        let memberExpense = group?.memberExpense?[indexPath.row]
        let memberData = group?.memberData?.filter { $0.userId == memberExpense?.userId }
        let userExpense = group?.memberExpense?.filter { $0.userId == currentUserId}
        if group?.creator == currentUserId {
            specificSettleUpViewController.userData = memberData?[0]
        } else {
            // MARK: - Bugs of not creator user
            specificSettleUpViewController.userData = creator
        }
        specificSettleUpViewController.memberExpense = memberExpense
        specificSettleUpViewController.groupId = group?.groupId
        specificSettleUpViewController.groupData = group
        specificSettleUpViewController.userExpense = userExpense ?? []
    
        self.show(specificSettleUpViewController, sender: nil)
    }
}
