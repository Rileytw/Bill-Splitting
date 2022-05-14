//
//  SettleUpViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/16.
//

import UIKit

class SettleUpViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var currentUserName: String?
    var creator: UserData?
    var groupData: GroupData?
    var memberExpense: [MemberExpense] = []
    var userData: [UserData] = []
    var expense: Double?
    var blackList = [String]()
    var leaveMemberData: [UserData] = []
    
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "結算群組帳務"
        ElementsStyle.styleBackground(view)
        getCurrentUserName()
        checkLeaveMember()
        getCreatorData()
        detectBlackListUser()
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
        if groupData?.creator == currentUserId {
            memberExpense = memberExpense.filter { $0.userId != currentUserId }
        }
    }
    
    func getCurrentUserName() {
        UserManager.shared.fetchSignInUserData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let user):
                self?.currentUserName = user?.userName
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
            }
        }
    }
    
    func getCreatorData() {
        for member in userData where member.userId == groupData?.creator {
            creator = member
        }
    }
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                                        userData: userData)
        userData = newUserData
        
        guard let creatorName = creator?.userName else { return }
        for user in blackList {
            if creator?.userId == user {
                creator?.userName = creatorName + "（已封鎖）"
            }
        }
    }
    
    func checkLeaveMember() {
        if leaveMemberData.isEmpty == false {
            for index in 0..<leaveMemberData.count {
                leaveMemberData[index].userName = leaveMemberData[index].userName + "（已離開群組）"
            }
            
            userData += leaveMemberData
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
            let revealExpense = memberExpense.allExpense
            if memberExpense.allExpense > 0 {
                settleUpCell.price.text = " $ " + String(format: "%.2f", revealExpense)
                settleUpCell.payerName.text = "\(currentUserName ?? "")"
                settleUpCell.creditorName.text = "\(memberData[0].userName)"
                
            } else {
//                settleUpCell.price.text = " $ \(abs(memberExpense.allExpense))"
                settleUpCell.price.text = " $ " + String(format: "%.2f", abs(revealExpense))
                settleUpCell.creditorName.text = "\(currentUserName ?? "")"
                settleUpCell.payerName.text = "\(memberData[0].userName)"
            }
        } else {
            if expense < 0 {
                settleUpCell.payerName.text = "\(currentUserName ?? "")"
                settleUpCell.creditorName.text = "\(creator?.userName ?? "")"
                settleUpCell.price.text = " $ " + String(format: "%.2f", abs(expense))
            } else {
                settleUpCell.price.text = " $ " + String(format: "%.2f", expense)
                settleUpCell.creditorName.text = "\(currentUserName ?? "")"
                settleUpCell.payerName.text = "\(creator?.userName ?? "")"
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
        if groupData?.creator == currentUserId {
            specificSettleUpViewController.userData = memberData[0]
//            specificSettleUpViewController.memberExpense = memberExpense
//            specificSettleUpViewController.groupId = groupData?.groupId
//            specificSettleUpViewController.groupData = groupData
//            specificSettleUpViewController.userExpense = userExpense
        } else {
            // MARK: - Bugs of not creator user
            specificSettleUpViewController.userData = creator
//            specificSettleUpViewController.memberExpense = memberExpense
//            specificSettleUpViewController.groupId = groupData?.groupId
//            specificSettleUpViewController.groupData = groupData
//            specificSettleUpViewController.userExpense = userExpense
        }
        specificSettleUpViewController.memberExpense = memberExpense
        specificSettleUpViewController.groupId = groupData?.groupId
        specificSettleUpViewController.groupData = groupData
        specificSettleUpViewController.userExpense = userExpense
    
        self.show(specificSettleUpViewController, sender: nil)
    }
}
