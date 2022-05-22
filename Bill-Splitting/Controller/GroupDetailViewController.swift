//
//  GroupDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class GroupDetailViewController: BaseViewController {

// MARK: - Property
    var tableView = UITableView()
    var leaveGroupButton = UIButton()
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var groupData: GroupData?
    var userData: [UserData] = []
    var personalExpense: Double?
    var memberExpense: Double = 0
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setLeaveGroupButton()
        setTableView()
        setAddGroupButton()
        detectBlockListUser()
        getMembersExpense()
    }

// MARK: - Method
    @objc func detectUserExpense() {
        if personalExpense == 0 && groupData?.creator != currentUserId {
            leaveGroupAlert()
        } else if memberExpense == 0 && groupData?.creator == currentUserId {
            creatorLeaveAlert()
        } else {
            rejectLeaveGroupAlert()
        }
    }
    
    func getMembersExpense() {
        guard let expense = groupData?.memberExpense else { return }
        let allExpense = expense.map { $0.allExpense }
        memberExpense = 0
        for member in allExpense {
            memberExpense += abs(member)
        }
    }
    
    @objc func pressEdit() {
        if groupData?.status == 0 {
            let storyBoard = UIStoryboard(name: StoryboardCategory.addGroups, bundle: nil)
            guard let addGroupViewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: AddGroupsViewController.self)) as? AddGroupsViewController else { return }
            addGroupViewController.isGroupExist = true
            addGroupViewController.group = groupData
            self.show(addGroupViewController, sender: nil)
        } else {
            editAlert()
        }
    }
    
    func setAddGroupButton() {
        let addButton = UIBarButtonItem.init(
            title: "編輯", style: UIBarButtonItem.Style.plain, target: self, action: #selector(pressEdit))
        self.navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    func editAlert() {
        let alertController = UIAlertController(title: "不可編輯", message: "已封存群組不可編輯群組內容", preferredStyle: .alert)
        let confirmAlert = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    func leaveGroupAlert() {
        let alertController = UIAlertController(title: "請確認是否退出群組",
                                                message: "退出群組後，將無法查看群組內容。",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確認退出", style: .destructive) { [weak self] _ in
            self?.leaveGroup()
            self?.backToGroupsPage()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func creatorLeaveAlert() {
        let alertController = UIAlertController(title: "請確認是否退出群組",
                                                message: "退出群組後，將無法查看群組內容。您退出群組後，群組將封存。",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確認退出", style: .destructive) { [weak self] _ in
            self?.closeGroup()
            self?.leaveGroup()
            self?.backToGroupsPage()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func rejectLeaveGroupAlert() {
        let alertController = UIAlertController(title: "無法退出群組",
                                                message: "您在群組內還有債務關係，無法退出。",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func hideLeaveButton() {
        if groupData?.creator == currentUserId {
            leaveGroupButton.isHidden = true
        }
    }
    
    func leaveGroup() {
        let groupId = groupData?.groupId
        GroupManager.shared.removeGroupMember(groupId: groupId ?? "",
                                              userId: currentUserId) { result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove group member failed")
            }
        }
        
        GroupManager.shared.removeGroupExpense(groupId: groupId ?? "",
                                               userId: currentUserId) { result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove member expense failed")
            }
        }
        
        GroupManager.shared.addLeaveMember(groupId: groupId ?? "",
                                           userId: currentUserId) { result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove member expense failed")
            }
            
        }
    }
    
    func backToGroupsPage() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func detectBlockListUser() {
        let blockList = UserManager.shared.currentUser?.blackList
        guard let blockList = blockList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList,
                                      userData: userData)
        userData = newUserData
    }
    
    func closeGroup() {
        if groupData?.creator == currentUserId {
            // MARK: - Add ProgressHUD when refactor, need to check situation
            GroupManager.shared.updateGroupStatus(groupId: groupData?.groupId ?? "") { [weak self] result in
                   switch result {
                   case .success:
                       self?.showSuccess(text: "成功封存群組")
                   case .failure:
                       self?.showFailure(text: "封存群組失敗，請稍後再試")
                   }
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension GroupDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return groupData?.member.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let groupData = groupData else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: GroupDetailTableViewCell.self),
                for: indexPath
            )
            guard let detailCell = cell as? GroupDetailTableViewCell else { return cell }
            
            detailCell.createDetailCell(groupName: groupData.groupName,
                                        content: groupData.groupDescription,
                                        groupType: groupData.type)
            
            return detailCell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: FriendListTableViewCell.self),
                for: indexPath
            )
            guard let memberCell = cell as? FriendListTableViewCell else { return cell }
            
            memberCell.infoButton.isHidden = true
            
            var memberData = [UserData]()
            
            for index in 0..<groupData.member.count {
                memberData += userData.filter { $0.userId == groupData.member[index] }
            }
            
            memberCell.profileItemName.text = memberData[indexPath.row].userName
            memberCell.email.text = memberData[indexPath.row].userEmail
            
            if memberData[indexPath.row].userId == groupData.creator {
                memberCell.profileItemName.text = memberData[indexPath.row].userName + "（群組創建人）"
            }
            
            return memberCell
        }
    }
}

extension GroupDetailViewController {
    func setTableViewConstraint() {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: leaveGroupButton.topAnchor, constant: -5).isActive = true
    }
    
    func setLeaveGroupButtonConstraint() {
        leaveGroupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        leaveGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        leaveGroupButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        leaveGroupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        setTableViewConstraint()
        tableView.register(UINib(nibName: String(describing: GroupDetailTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: GroupDetailTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: FriendListTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: FriendListTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setLeaveGroupButton() {
        view.addSubview(leaveGroupButton)
        leaveGroupButton.translatesAutoresizingMaskIntoConstraints = false
        setLeaveGroupButtonConstraint()
        leaveGroupButton.setTitle("退出群組", for: .normal)
        leaveGroupButton.setTitleColor(.greenWhite, for: .normal)
        ElementsStyle.styleSpecificButton(leaveGroupButton)
        leaveGroupButton.addTarget(self, action: #selector(detectUserExpense), for: .touchUpInside)
    }
}
