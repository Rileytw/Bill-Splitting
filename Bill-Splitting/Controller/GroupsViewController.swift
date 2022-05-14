//
//  GroupsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import SwiftUI
import Lottie

class GroupsViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    
    let selectedSource = [
        ButtonModel(title: "所有群組"),
        ButtonModel(title: "多人支付"),
        ButtonModel(title: "個人預付"),
        ButtonModel(title: "封存群組")
    ]
    let selectedView = SelectionView(frame: .zero)
    let tableView = UITableView()
    private var animationView = AnimationView()
    var blockUserView = BlockUserView()
    var mask = UIView()
    var searchView = UIView()
    var emptyLabel = UILabel()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    var groups: [GroupData] = []    
    var multipleGroups: [GroupData] = []
    var personalGroups: [GroupData] = []
    var closedGroups: [GroupData] = []
    var filteredGroups: [GroupData] = []
    var blackList: [String] = []
    var personalExpense: Double?
    var group: GroupData?
    var memberExpense: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewBackground()
        setSelectedView()
        setSearchView()
        setEmptyLabel()
        setTableView()
        navigationItem.title = "我的群組"
        setSearchBar()
        setAnimation()
        networkDetect()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
        getClosedGroupData()
        fetchCurrentUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NetworkStatus.shared.stopMonitoring()
    }
    
    func setSearchView() {
        view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        setSearchViewConstraint()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        setTableViewConstraint()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
        tableView.register(UINib(nibName: String(describing: GroupsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: GroupsTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                group = groups[indexPath.row]
                getMemberExpense(groupId: groups[indexPath.row].groupId,
                                 members: groups[indexPath.row].member)
                
            }
        }
    }
    
    func getGroupData() {
        GroupManager.shared.fetchGroupsRealTime(userId: currentUserId, status: 0) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                self?.setFilterGroupData()
                if groups.isEmpty == true {
                    self?.emptyLabel.isHidden = false
                } else {
                    self?.emptyLabel.isHidden = true
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
            }
        }
    }
    
    func getClosedGroupData() {
        GroupManager.shared.fetchGroupsRealTime(userId: currentUserId, status: 1) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.closedGroups = groups
                self?.setFilterGroupData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
            }
        }
    }
    
    func fetchCurrentUserData() {
        UserManager.shared.fetchUserData(friendId: currentUserId) { [weak self] result in
            switch result {
            case .success(let currentUserData):
                if currentUserData?.blackList != nil {
                    self?.blackList = currentUserData?.blackList ?? []
                }
                print("success")
            case .failure(let error):
                print("\(error.localizedDescription)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
            }
        }
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        searchView.addSubview(searchBar)
        searchBar.barTintColor = UIColor.hexStringToUIColor(hex: "A0B9BF")
        searchBar.searchTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        searchBar.tintColor = UIColor.hexStringToUIColor(hex: "E5DFDF")
        searchBar.searchTextField.textColor = .styleBlue
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        guard let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton else { return }
        cancelButton.setTitle("取消", for: .normal)
    }
    
    func searchGroup(_ searchTerm: String) {
        if searchTerm.isEmpty {
            setFilterGroupData()
        } else {
            switch selectedView.buttonIndex {
            case 0:
                filteredGroups = groups.filter {
                    $0.groupName.localizedCaseInsensitiveContains(searchTerm)
                }
            case 1:
                filteredGroups = multipleGroups.filter {
                    $0.groupName.localizedCaseInsensitiveContains(searchTerm)
                }
            case 2:
                filteredGroups = personalGroups.filter {
                    $0.groupName.localizedCaseInsensitiveContains(searchTerm)
                }
            case 3:
                filteredGroups = closedGroups.filter {
                    $0.groupName.localizedCaseInsensitiveContains(searchTerm)
                }
            default:
                filteredGroups = groups.filter {
                    $0.groupName.localizedCaseInsensitiveContains(searchTerm)
                }
            }
            tableView.reloadData()
        }
    }
    func setFilterGroupData() {
        if selectedView.buttonIndex == 0 {
            filteredGroups = groups
        } else if selectedView.buttonIndex == 1 {
            filteredGroups = multipleGroups
        } else if selectedView.buttonIndex == 2 {
            filteredGroups = personalGroups
        } else if selectedView.buttonIndex == 3 {
            filteredGroups = closedGroups
        } else {
            filteredGroups = groups
        }
        tableView.reloadData()
        removeAnimation()
    }
    
    func setSelectedView() {
        view.addSubview(selectedView)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        selectedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        selectedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        selectedView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        selectedView.selectionViewDataSource = self
        selectedView.selectionViewDelegate = self
    }
    
    func setViewBackground() {
        ElementsStyle.styleBackground(view)
    }
    
    func setAnimation() {
        animationView = .init(name: "accountLoading")
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        animationView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        animationView.play()
    }
    
    func removeAnimation() {
        animationView.stop()
        animationView.removeFromSuperview()
    }
    
    func networkDetect() {
        NetworkStatus.shared.startMonitoring()
        NetworkStatus.shared.netStatusChangeHandler = {
            if NetworkStatus.shared.isConnected == true {
                print("connected")
            } else {
                print("Not connected")
                if !Thread.isMainThread {
                    DispatchQueue.main.async {
                        ProgressHUD.shared.view = self.view
                        ProgressHUD.showFailure(text: "網路未連線，請連線後再試")
                    }
                }
            }
        }
    }
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: GroupsTableViewCell.self),
            for: indexPath
        )
        
        guard let groupsCell = cell as? GroupsTableViewCell else { return cell }
        
        groupsCell.groupName.text = filteredGroups[indexPath.row].groupName
        
        if filteredGroups[indexPath.row].type == 1 {
            groupsCell.groupType.text = "多人支付"
            groupsCell.setIcon(style: 1)
        } else {
            groupsCell.groupType.text = "個人預付"
            groupsCell.setIcon(style: 0)
        }
        
        groupsCell.numberOfMembers.text = "成員人數：" + String(filteredGroups[indexPath.row].member.count) + "人"
        groupsCell.backgroundColor = UIColor.clear
        
        return groupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let customGroupViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: CustomGroupViewController.self)) as? CustomGroupViewController else { return }
        customGroupViewController.groupData = filteredGroups[indexPath.row]
        customGroupViewController.blackList = blackList
        self.show(customGroupViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    private func animateTableView() {
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            UIView.animate(withDuration: 0.8,
                           delay: 0.05 * Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        }
    }
    
}

extension GroupsViewController: SelectionViewDataSource, SelectionViewDelegate {
    func numberOfSelectionView(_ selectionView: SelectionView) -> Int {
        return selectedSource.count
    }
    
    func labelOfSelectionView(_ selectionView: SelectionView) -> [ButtonModel] {
        return selectedSource
    }
    
    func didSelectedButton(_ selectionView: SelectionView, at index: Int) {
        if selectionView.buttonIndex == 0 {
            setFilterGroupData()
        } else if selectedView.buttonIndex == 1 {
            multipleGroups = groups.filter { $0.type == GroupType.multipleUsers.typeInt }
            setFilterGroupData()
        } else if selectedView.buttonIndex == 2 {
            personalGroups = groups.filter { $0.type == GroupType.personal.typeInt }
            setFilterGroupData()
        } else {
            setFilterGroupData()
        }
    }
}

extension GroupsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchTerm = searchBar.text ?? ""
        searchGroup(searchTerm)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        setFilterGroupData()
    }
}

extension GroupsViewController {
    func revealBlockView() {
        mask = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        mask.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(mask)
        
        blockUserView = BlockUserView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 300))
        blockUserView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        blockUserView.buttonTitle = " 退出群組"
        blockUserView.content = "退出群組後，將無法查看群組內容。"
        blockUserView.blockUserButton.setImage(UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"), for: .normal)
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.blockUserView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        }, completion: nil)
        view.addSubview(blockUserView)
        
        blockUserView.blockUserButton.addTarget(self, action: #selector(detectUserExpense), for: .touchUpInside)
        blockUserView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func pressDismissButton() {
        let subviewCount = self.view.subviews.count
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.subviews[subviewCount - 1].frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }, completion: nil)
        mask.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func getMemberExpense(groupId: String, members: [String]) {
        GroupManager.shared.fetchMemberExpenseForBlock(groupId: groupId, members: members) { [weak self] result in
            switch result {
            case .success(let expense):
                let personalExpense = expense.filter { $0.userId == (self?.currentUserId ?? "") }
                if personalExpense.isEmpty == false {
                    self?.personalExpense = personalExpense[0].allExpense
                    let allExpense = expense.map { $0.allExpense }
                    self?.memberExpense = 0
                    for member in allExpense {
                        self?.memberExpense += abs(member)
                    }
                    self?.revealBlockView()
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
            }
        }
    }
    
    @objc func detectUserExpense() {
        if personalExpense == 0 && group?.creator != currentUserId {
            leaveGroupAlert()
        } else if memberExpense == 0 && group?.creator == currentUserId{
            creatorLeaveAlert()
        } else {
            rejectLeaveGroupAlert()
        }
    }
    
    func leaveGroupAlert() {
        let alertController = UIAlertController(title: "請確認是否退出群組",
                                                message: "退出群組後，將無法查看群組內容。",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確認退出", style: .destructive) { [weak self] _ in
            self?.leaveGroup()
            self?.pressDismissButton()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func leaveGroup() {
        let groupId = group?.groupId
        GroupManager.shared.removeGroupMember(groupId: groupId ?? "",
                                              userId: currentUserId) { [weak self] result in
            switch result {
            case .success:
                print("leave group")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showSuccess(text: "成功退出群組")
                self?.getGroupData()
            case .failure:
                print("remove group member failed")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "退出失敗，請稍後再試")
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
                                           userId: currentUserId) {
            result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove member expense failed")
            }
        }
    }
    
    func creatorLeaveAlert() {
        let alertController = UIAlertController(title: "請確認是否退出群組",
                                                message: "退出群組後，將無法查看群組內容。您退出群組後，群組將封存。",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "確認退出", style: .destructive) { [weak self] _ in
            self?.closeGroup()
            self?.leaveGroup()
            self?.pressDismissButton()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func closeGroup() {
        if group?.creator == currentUserId {
            GroupManager.shared.updateGroupStatus(groupId: group?.groupId ?? "")
        }
    }
    
    func rejectLeaveGroupAlert() {
        let alertController = UIAlertController(title: "無法退出群組",
                                                message: "您在群組內還有債務關係，無法退出。",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setTableViewConstraint() {
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setSearchViewConstraint() {
        searchView.topAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 5).isActive = true
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func setEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.text = "目前暫無資料，前往【新增群組】建立自己的群組吧！"
        emptyLabel.textColor = .greenWhite
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 5).isActive = true
        emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emptyLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        emptyLabel.isHidden = true
    }
}
