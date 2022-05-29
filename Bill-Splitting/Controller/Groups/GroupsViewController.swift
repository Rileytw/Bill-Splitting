//
//  GroupsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import SwiftUI

class GroupsViewController: BaseViewController {
    // MARK: - Property
    let selectedSource = [
        ButtonModel(title: GroupButton.allGroups.buttonName),
        ButtonModel(title: GroupButton.multipleUsers.buttonName),
        ButtonModel(title: GroupButton.personal.buttonName),
        ButtonModel(title: GroupButton.close.buttonName)
    ]
    let selectedView = SelectionView(frame: .zero)
    let tableView = UITableView()
    var blockUserView = BlockUserView()
    var blockUserViewBottom: NSLayoutConstraint?
    var searchView = UIView()
    var emptyLabel = UILabel()
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var groups: [GroupData] = []
    var multipleGroups: [GroupData] = []
    var personalGroups: [GroupData] = []
    var closedGroups: [GroupData] = []
    var filteredGroups: [GroupData] = []
    var personalExpense: Double?
    var group: GroupData?
    var memberExpense: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUserData()
        setViewBackground()
        setSelectedView()
        setSearchView()
        setEmptyLabel()
        setTableView()
        navigationItem.title = NavigationItemName.allGroups.name
        setSearchBar()
        setAnimation()
        networkDetect()
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
        getClosedGroupData()
        fetchCurrentUserData()
    }
    
    // MARK: - Method
    func fetchCurrentUserData() {
        UserManager.shared.fetchSignInUserData(userId: currentUserId) { [weak self] result in
            if case .failure = result {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
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
        GroupManager.shared.fetchGroupsRealTime(
            userId: currentUserId, status: GroupStatus.active.typeInt) { [weak self] result in
                switch result {
                case .success(let groups):
                    self?.groups = groups
                    self?.setFilterGroupData()
                    self?.hideEmptyLabel(groups)
                case .failure:
                    self?.showFailure(text: ErrorType.dataFetchError.errorMessage)
                }
            }
    }
    
    func getClosedGroupData() {
        GroupManager.shared.fetchGroupsRealTime(
            userId: currentUserId, status: GroupStatus.inActive.typeInt) { [weak self] result in
                switch result {
                case .success(let groups):
                    self?.closedGroups = groups
                    self?.setFilterGroupData()
                case .failure:
                    self?.showFailure(text: ErrorType.dataFetchError.errorMessage)
                }
            }
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        searchView.addSubview(searchBar)
        ElementsStyle.styleSearchBar(searchBar)
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
        setSelectedViewConstraint()
        
        selectedView.selectionViewDataSource = self
        selectedView.selectionViewDelegate = self
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
            groupsCell.groupType.text = GroupType.multipleUsers.typeName
            groupsCell.setIcon(style: 1)
        } else {
            groupsCell.groupType.text = GroupType.personal.typeName
            groupsCell.setIcon(style: 0)
        }
        
        groupsCell.numberOfMembers.text = "成員人數：" + String(filteredGroups[indexPath.row].member.count) + "人"
        groupsCell.backgroundColor = UIColor.clear
        
        return groupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let customGroupViewController =
                storyBoard.instantiateViewController(
                    withIdentifier: String(describing: CustomGroupViewController.self)
                ) as? CustomGroupViewController else { return }
        customGroupViewController.group = filteredGroups[indexPath.row]
        self.show(customGroupViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        TableViewAnimation.hightlight(cell: cell)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        TableViewAnimation.unHightlight(cell: cell)
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
        mask.backgroundColor = .maskBackgroundColor
        view.stickSubView(mask)
        
        setBlockUserView()
        blockUserViewBottom?.constant = -300
        blockUserView.buttonTitle = " 退出群組"
        blockUserView.content = "退出群組後，將無法查看群組內容。"
        blockUserView.blockUserButton.setImage(
            UIImage(systemName: "rectangle.portrait.and.arrow.right.fill"), for: .normal)
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        
        blockUserView.blockUserButton.addTarget(self, action: #selector(detectUserExpense), for: .touchUpInside)
        blockUserView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private func setBlockUserView() {
        blockUserView.removeFromSuperview()
        view.addSubview(blockUserView)
        blockUserView.translatesAutoresizingMaskIntoConstraints = false
        blockUserView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blockUserView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        blockUserView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        blockUserViewBottom = blockUserView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        blockUserViewBottom?.isActive = true
        blockUserView.backgroundColor = .viewDarkBackgroundColor
        
        view.layoutIfNeeded()
    }
    
    @objc func pressDismissButton() {
        blockUserViewBottom?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
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
            case .failure:
                self?.showFailure(text: ErrorType.dataFetchError.errorMessage)
            }
        }
    }
    
    @objc func detectUserExpense() {
        if personalExpense == 0 && group?.creator != currentUserId {
            leaveGroupAlert()
        } else if memberExpense == 0 && group?.creator == currentUserId {
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
        guard let groupId = group?.groupId else { return }
        LeaveGroupManager.shared.leaveGroup(groupId: groupId, currentUserId: currentUserId) { [weak self] in
            if LeaveGroupManager.shared.isLeaveGroupSuccess == true {
                self?.showSuccess(text: "成功退出群組")
                self?.getGroupData()
            } else {
                self?.showSuccess(text: ErrorType.generalError.errorMessage)
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
            self?.pressDismissButton()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func closeGroup() {
        if group?.creator == currentUserId {
            GroupManager.shared.updateGroupStatus(groupId: group?.groupId ?? "") { [weak self] result in
                switch result {
                case .success:
                    self?.leaveGroup()
                case .failure:
                    self?.showFailure(text: "封存群組失敗，請稍後再試")
                }
            }
        }
    }
    
    func rejectLeaveGroupAlert() {
        confirmAlert(title: "無法退出群組", message: "您在群組內還有債務關係，無法退出。")
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
        emptyLabel.text = "目前暫無資料，前往【新增群組】建立群組吧！"
        emptyLabel.adjustsFontSizeToFitWidth = true
        emptyLabel.textColor = .greenWhite
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 5).isActive = true
        emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        emptyLabel.isHidden = true
    }
    
    fileprivate func setSelectedViewConstraint() {
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        selectedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        selectedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        selectedView.heightAnchor.constraint(equalToConstant: 60).isActive = true
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
    
    private func hideEmptyLabel(_ groups: ([GroupData])) {
        if groups.isEmpty == true {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
        }
    }
    
    func setViewBackground() {
        ElementsStyle.styleBackground(view)
    }
}
