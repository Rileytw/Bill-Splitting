//
//  ViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/8.
//

import UIKit

class AddGroupsViewController: BaseViewController {
// MARK: - Property
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var nameTextField = UITextField()
    let descriptionTextView = UITextView()
    var searchView = UIView()
    
    let typeLabel = UILabel()
    var typePickerView = BasePickerViewInTextField(frame: .zero)
    var pickerViewData = [GroupType.multipleUsers.typeName, GroupType.personal.typeName]
    var selectMemberLabel = UILabel()
    
    var friendList: [Friend] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    let inviteFriendButton = UIButton()
    let addGroupButton = UIButton()
    
    var member: [String] = []
    
    var isGroupExist: Bool = false
    var group: GroupData?
    var filteredMembers: [FriendSearchModel] = []
    var friends: [FriendSearchModel] = []
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setTextField()
        setTextView()
        setTextFieldOfPickerView()
        setAddGroupButton()
        setInviteButton()
        setSelectMamberLabel()
        setSearchView()
        setTableView()
        navigationItem.title = "新增群組"
        setSearchBar()
        
        hideUnchagableGroupInfo()
        networkDetect()
        setAnimation()
        listenNewFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFriendData()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        ElementsStyle.styleTextField(nameTextField)
    }
    
// MARK: - Method
    func setAddGroupButton() {
        var buttonName: String
        if isGroupExist == true {
            buttonName = "儲存"
        } else {
            buttonName = "完成"
        }
        
        let addButton = UIBarButtonItem.init(title: buttonName,
                                             style: UIBarButtonItem.Style.plain,
                                             target: self, action: #selector(pressAddGroupButton))
        self.navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    @objc func pressAddGroupButton() {
        if nameTextField.text?.isEmpty == true {
            loseGroupInfoAlert(message: "尚未填寫群組名稱")
        } else if typePickerView.textField.text == "" && isGroupExist == false {
            loseGroupInfoAlert(message: "尚未選擇群組類型")
        } else {
            if NetworkStatus.shared.isConnected == true {
                addMembers()
                if isGroupExist == true {
                    updateExistGroupData()
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    uploadGroupData()
                }
                cleanData()
            } else {
                networkConnectAlert()
            }
        }
    }
    
    func fetchFriendData() {
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.friendList.removeAll()
                self?.friends.removeAll()
                self?.friendList = friend
                self?.selectedNewMember()
                self?.setFilterFriendsData()
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func listenNewFriends() {
        if isGroupExist == false {
            UserManager.shared.listenFriendData(userId: currentUserId) { [weak self]  in
                self?.fetchFriendData()
            }
        }
    }
    
    func addMembers() {
        let selectedMember = friends.filter { $0.isSelected == true }
        member = selectedMember.map { $0.friendList.userId }
    }
    
    func updateExistGroupData() {
        guard let groupId = group?.groupId else { return }
        GroupManager.shared.updateGroupData(groupId: groupId,
                                            groupName: nameTextField.text ?? "",
                                            groupDescription: descriptionTextView.text,
                                            memberName: member) { [weak self] result in
            switch result {
            case .success:
                self?.updateMemberExpense(groupId)
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
            
        }
//        updateMemberExpense(groupId)
    }
    
    private func updateMemberExpense(_ groupId: (String)) {
        member.forEach { member in
            GroupManager.shared.addMemberExpenseData(
                userId: member, allExpense: 0, groupId: groupId) { [weak self] result in
                switch result {
                case .success:
                    if member == self?.member.last {
                        self?.showSuccess(text: "已新增群組")
                    }
                case .failure:
                    self?.showFailure(text: ErrorType.generalError.errorMessage)
                }
            }
        }
    }
    
    private func createGroup(_ type: Int?) -> GroupData {
        var group = GroupData()
        group.groupName = nameTextField.text ?? ""
        group.groupDescription = descriptionTextView.text
        group.creator = currentUserId
        group.type = type ?? 0
        group.status = 0
        group.member = self.member
        group.createdTime = Double(NSDate().timeIntervalSince1970)
        return group
    }
    
    func uploadGroupData() {
        member.append(currentUserId)
        
        var type: Int?
        if typePickerView.textField.text == GroupType.personal.typeName {
            type = GroupType.personal.typeInt
        } else {
            type = GroupType.multipleUsers.typeInt
        }

        let group = createGroup(type)
        GroupManager.shared.addGroupData(group: group) { [weak self] result in
            switch result {
            case .success(let groupId):
                self?.updateMemberExpense(groupId)
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func cleanData() {
        nameTextField.text? = ""
        descriptionTextView.text = ""
        for index in 0..<filteredMembers.count {
            if filteredMembers[index].isSelected == true {
                filteredMembers[index].isSelected = false
            }
        }
        tableView.reloadData()
        member.removeAll()
    }
    
    @objc func pressInviteFriendButton() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.addGroups, bundle: nil)
        let inviteFriendViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: InviteFriendViewController.self))
        if #available(iOS 15.0, *) {
            if let sheet = inviteFriendViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.preferredCornerRadius = 20
            }
        }
        self.present(inviteFriendViewController, animated: true, completion: nil)
    }
    
    func loseGroupInfoAlert(message: String) {
        confirmAlert(title: "請填寫完整資訊", message: message)
    }
    
    func selectedNewMember() {
        var newGroupMember = friendList
        if isGroupExist == true {
            guard let groupMember = group?.member else { return }
            for member in 0..<friendList.count {
                for index in 0..<groupMember.count {
                    if friendList[member].userId == groupMember[index] {
                        newGroupMember.remove(at: newGroupMember.firstIndex(of: friendList[member])!)
                    }
                }
            }
            friendList = newGroupMember
            for index in 0..<newGroupMember.count {
                let friendModel = FriendSearchModel(friendList: newGroupMember[index], isSelected: false)
                filteredMembers.append(friendModel)
            }
        }
        for index in 0..<friendList.count {
            let friendModel = FriendSearchModel(friendList: friendList[index], isSelected: false)
            friends.append(friendModel)
        }
        setFilterFriendsData()
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        searchView.addSubview(searchBar)
        ElementsStyle.styleSearchBar(searchBar)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        guard let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton else { return }
        cancelButton.setTitle("取消", for: .normal)
    }
    
    func searchGroup(_ searchTerm: String) {
        if searchTerm.isEmpty {
            setFilterFriendsData()
        } else {
            filteredMembers = friends.filter {
                $0.friendList.userName.localizedCaseInsensitiveContains(searchTerm)
            }
            tableView.reloadData()
        }
    }
    
    func setFilterFriendsData() {
        filteredMembers = friends
        tableView.reloadData()
        removeAnimation()
    }
    
    func networkConnectAlert() {
        confirmAlert(title: "網路未連線", message: "網路未連線，無法新增群組資料，請確認網路連線後再新增群組。")
    }
}

extension AddGroupsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerViewData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typePickerView.textField.text = pickerViewData[row]
    }
}

extension AddGroupsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableView.automaticDimension
        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AddGroupTableViewCell.self),
            for: indexPath
        )
        
        guard let addGroupsCell = cell as? AddGroupTableViewCell else { return cell }
        
        addGroupsCell.friendNameLabel.text = filteredMembers[indexPath.row].friendList.userName
        
        if filteredMembers[indexPath.row].isSelected == true {
            addGroupsCell.selectedButton.isSelected = true
        } else {
            addGroupsCell.selectedButton.isSelected = false
        }
        
        return addGroupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filteredMembers[indexPath.row].isSelected.toggle()
        for index in 0..<friends.count {
            if friends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                friends[index].isSelected.toggle()
            }
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        filteredMembers[indexPath.row].isSelected.toggle()
        for index in 0..<friends.count {
            if friends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                friends[index].isSelected.toggle()
            }
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddGroupsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchTerm = searchBar.text ?? ""
        searchGroup(searchTerm)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        setFilterFriendsData()
    }
}

extension AddGroupsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == true {
            typePickerView.pickerView.selectRow(0, inComponent: 0, animated: true)
            self.pickerView(typePickerView.pickerView, didSelectRow: 0, inComponent: 0)
        }
    }
}

extension AddGroupsViewController {
    func setTextField() {
        self.view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameTextField, attribute: .top, relatedBy: .equal,
                           toItem: view.safeAreaLayoutGuide, attribute: .top,
                           multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1,
                           constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .width, relatedBy: .equal,
                           toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "群組名稱"
        nameLabel.textColor = .greenWhite
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal,
                           toItem: view.safeAreaLayoutGuide, attribute: .top,
                           multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal,
                           toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
    }
    
    func setTextView() {
        self.view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionTextView, attribute: .top, relatedBy: .equal,
                           toItem: nameTextField, attribute: .bottom, multiplier: 1, constant: 16).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1,
                           constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .width, relatedBy: .equal,
                           toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 60).isActive = true
        ElementsStyle.styleTextView(descriptionTextView)
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "群組簡介"
        descriptionLabel.textColor = .greenWhite
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal,
                           toItem: nameTextField, attribute: .top, multiplier: 1, constant: 25).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .width, relatedBy: .equal,
                           toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
    }
    
    func setTextFieldOfPickerView() {
        view.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16).isActive = true
        typeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        typeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        typeLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeLabel.text = "群組類型"
        typeLabel.textColor = .greenWhite
        
        view.addSubview(typePickerView)
        typePickerView.translatesAutoresizingMaskIntoConstraints = false
        typePickerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typePickerView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16).isActive = true
        typePickerView.widthAnchor.constraint(equalTo: descriptionTextView.widthAnchor).isActive = true
        typePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        typePickerView.pickerViewData = pickerViewData
        typePickerView.pickerView.dataSource = self
        typePickerView.pickerView.delegate = self
        typePickerView.textField.delegate = self
    }
    
    func setSelectMamberLabel() {
        view.addSubview(selectMemberLabel)
        selectMemberLabel.translatesAutoresizingMaskIntoConstraints = false
        selectMemberLabel.topAnchor.constraint(equalTo: typePickerView.bottomAnchor, constant: 16).isActive = true
        selectMemberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        selectMemberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        selectMemberLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        selectMemberLabel.text = "選擇參與群組成員"
        selectMemberLabel.textColor = .greenWhite
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor, constant: 5).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: inviteFriendButton.topAnchor, constant: 0).isActive = true
        tableView.register(UINib(nibName: String(describing: AddGroupTableViewCell.self),
                                 bundle: nil), forCellReuseIdentifier: String(describing: AddGroupTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setInviteButton() {
        inviteFriendButton.setTitle("邀請好友", for: .normal)
        inviteFriendButton.setImage(UIImage(systemName: "plus"), for: .normal)
        ElementsStyle.styleSpecificButton(inviteFriendButton)
        view.addSubview(inviteFriendButton)
        inviteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inviteFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        inviteFriendButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        inviteFriendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -10).isActive = true
        
        inviteFriendButton.addTarget(self, action: #selector(pressInviteFriendButton), for: .touchUpInside)
    }
    
    func hideUnchagableGroupInfo() {
        if isGroupExist == true {
            nameTextField.text = group?.groupName
            descriptionTextView.text = group?.groupDescription
            
            typePickerView.isHidden = true
            typeLabel.isHidden = true
            
            if group?.creator != currentUserId {
                tableView.isHidden = true
            }
        }
    }
    
    func setSearchView() {
        view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        setSearchViewConstraint()
    }
    
    func setSearchViewConstraint() {
        searchView.topAnchor.constraint(equalTo: selectMemberLabel.bottomAnchor, constant: 8).isActive = true
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
