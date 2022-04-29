//
//  ViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/8.
//

import UIKit

struct FriendSearchModel {
    var friendList: Friend
    var isSelected: Bool
}

class AddGroupsViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var nameTextField = UITextField()
    let descriptionTextView = UITextView()
    
    let fullScreenSize = UIScreen.main.bounds.size
    var typeTextField = UITextField()
    
    var pickerView: UIPickerView!
    var pickerViewData = [GroupType.multipleUsers.typeName, GroupType.personal.typeName]
    
    var friendList: [Friend] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let tableView = UITableView()
    var searchController: UISearchController!
    
    let inviteFriendButton = UIButton()
    let addGroupButton = UIButton()
    
    var member: [String] = []
    
    var isGroupExist: Bool = false
    var groupData: GroupData?
    var newGroupMember = [Friend]()
    var filteredMembers: [FriendSearchModel] = []
    
    var friends: [FriendSearchModel] = []
    var newGroupFriends: [FriendSearchModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextField()
        setTextView()
        setUpPickerView(data: pickerViewData)
        
        setTextFieldOfPickerView()
        setAddGroupButton()
        setInviteButton()
        setTableView()
        //        setSearchBar()
        nameTextField.delegate = self
        navigationItem.title = "新增群組"
        setSearchBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.fetchFriendData(userId: currentUserId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.friendList = friend
                if self?.isGroupExist == true {
                    self?.selectedNewMember()
                }
                for index in 0..<friend.count {
                    let friendModel = FriendSearchModel(friendList: friend[index], isSelected: false)
                    self?.friends.append(friendModel)
                }
                self?.setFilterGroupData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        friends.removeAll()
        newGroupFriends.removeAll()
    }
    
    func setAddGroupButton() {
        let addButton = UIBarButtonItem.init(title: "建立群組", style: UIBarButtonItem.Style.plain, target: self, action: #selector(pressAddGroupButton))
        self.navigationItem.setRightBarButton(addButton, animated: true)
    }
    
    @objc func pressAddGroupButton() {
        if nameTextField.text?.isEmpty == true {
            loseGroupNameAlert()
        } else {
            addMembers()
            
            if isGroupExist == true {
                guard let groupId = groupData?.groupId else { return }
                GroupManager.shared.updateGroupData(groupId: groupId,
                                                    groupName: nameTextField.text ?? "",
                                                    groupDescription: descriptionTextView.text,
                                                    memberName: member)
                self.member.forEach { member in
                    GroupManager.shared.addMemberExpenseData(userId: member, allExpense: 0, groupId: groupId)
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                member.append(currentUserId)
                
                var type: Int?
                
                if typeTextField.text == GroupType.personal.typeName {
                    type = 0
                } else {
                    type = 1
                }
                
                GroupManager.shared.addGroupData(name: nameTextField.text ?? "",
                                                 description: descriptionTextView.text,
                                                 creator: currentUserId,
                                                 type: type ?? 0,
                                                 status: 0,
                                                 member: self.member,
                                                 createdTime: Double(NSDate().timeIntervalSince1970)) {
                    groupId in
                    self.member.forEach { member in
                        GroupManager.shared.addMemberExpenseData(userId: member, allExpense: 0, groupId: groupId)
                    }
                }
            }
            
            self.nameTextField.text? = ""
            self.descriptionTextView.text = ""

            for index in 0..<filteredMembers.count {
                if filteredMembers[index].isSelected == true {
                    filteredMembers[index].isSelected = false
                }
            }
            
            self.tableView.reloadData()
            self.member.removeAll()
        }
    }
    
    func addMembers() {
        if isGroupExist == true {
            let selectedMember = newGroupFriends.filter { $0.isSelected == true }
            member = selectedMember.map { $0.friendList.userId }
        } else {
            let selectedMember = friends.filter { $0.isSelected == true }
            member = selectedMember.map { $0.friendList.userId }
        }
    }
    
    @objc func pressInviteFriendButton() {
        let storyBoard = UIStoryboard(name: "AddGroups", bundle: nil)
        let inviteFriendViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: InviteFriendViewController.self))
        self.present(inviteFriendViewController, animated: true, completion: nil)
    }
    
    func loseGroupNameAlert() {
        let alertController = UIAlertController(title: "請填寫完整資訊", message: "尚未填寫群組名稱", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func selectedNewMember() {
        guard let groupMember = groupData?.member else {
            return
        }
        
        newGroupMember = friendList
        for member in 0..<friendList.count {
            for index in 0..<groupMember.count {
                if friendList[member].userId == groupMember[index] {
                    newGroupMember.remove(at: newGroupMember.firstIndex(of: friendList[member])!)
                }
            }
        }
        
        for index in 0..<newGroupMember.count {
            let friendModel = FriendSearchModel(friendList: newGroupMember[index], isSelected: false)
            newGroupFriends.append(friendModel)
        }
        
        setFilterGroupData()
        tableView.reloadData()
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        tableView.tableHeaderView = searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        guard let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton else { return }
        cancelButton.setTitle("取消", for: .normal)
    }
    
    func searchGroup(_ searchTerm: String) {
        if searchTerm.isEmpty {
            setFilterGroupData()
        } else {
            if isGroupExist == true {
                filteredMembers = newGroupFriends.filter {
                    $0.friendList.userName.contains(searchTerm)
                }
            } else {
                filteredMembers = friends.filter {
                    $0.friendList.userName.contains(searchTerm)
                }
            }
            tableView.reloadData()
        }
    }
    
    func setFilterGroupData() {
        if isGroupExist == true {
            filteredMembers = newGroupFriends
        } else {
            filteredMembers = friends
        }
        tableView.reloadData()
    }
    
    func setTextField() {
        nameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        nameTextField.layer.borderColor = UIColor.black.cgColor
        nameTextField.layer.borderWidth = 1
        self.view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameTextField, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "群組名稱"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        if isGroupExist == true {
            nameTextField.text = groupData?.groupName
        }
    }
    
    func setTextView() {
        descriptionTextView.layer.borderWidth = 1
        self.view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionTextView, attribute: .top, relatedBy: .equal, toItem: nameTextField, attribute: .bottom, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: descriptionTextView,attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 60).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "群組簡介"
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: nameTextField, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: descriptionLabel,attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: descriptionLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
        
        if isGroupExist == true {
            descriptionTextView.text = groupData?.groupDescription
        }
    }
    
    func setUpPickerView(data:[String]) {
        pickerViewData = data
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func setTextFieldOfPickerView() {
        //        typeTextField = UITextField(frame: .zero)
        self.view.addSubview(typeTextField)
        typeTextField.translatesAutoresizingMaskIntoConstraints = false
        typeTextField.widthAnchor.constraint(equalToConstant: fullScreenSize.width).isActive = true
        typeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 20).isActive = true
        typeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        typeTextField.inputView = pickerView
        typeTextField.text = pickerViewData[0]
        typeTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        typeTextField.textAlignment = .center
        
        if isGroupExist == true {
            typeTextField.isHidden = true
        }
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: typeTextField.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: inviteFriendButton.topAnchor, constant: 0).isActive = true
        tableView.register(UINib(nibName: String(describing: AddGroupTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddGroupTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func setInviteButton() {
        inviteFriendButton.setTitle("邀請好友", for: .normal)
        inviteFriendButton.setImage(UIImage(systemName: "plus"), for: .normal)
        inviteFriendButton.tintColor = .systemGray
        inviteFriendButton.setTitleColor(.systemGray, for: .normal)
        view.addSubview(inviteFriendButton)
        inviteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inviteFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        inviteFriendButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inviteFriendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        
        inviteFriendButton.addTarget(self, action: #selector(pressInviteFriendButton), for: .touchUpInside)
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
        typeTextField.text = pickerViewData[row]
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
            cell.accessoryType = .checkmark
            addGroupsCell.selectedButton.isSelected = true
        } else {
            cell.accessoryType = .none
            addGroupsCell.selectedButton.isSelected = false
        }
        
        return addGroupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filteredMembers[indexPath.row].isSelected.toggle()
        
        if isGroupExist == true {
            for index in 0..<newGroupFriends.count {
                if newGroupFriends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                    newGroupFriends[index].isSelected.toggle()
                }
            }
        } else {
            for index in 0..<friends.count {
                if friends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                    friends[index].isSelected.toggle()
                }
            }
        }

        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        filteredMembers[indexPath.row].isSelected.toggle()
        
        if isGroupExist == true {
            for index in 0..<newGroupFriends.count {
                if newGroupFriends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                    newGroupFriends[index].isSelected.toggle()
                }
            }
        } else {
            for index in 0..<friends.count {
                if friends[index].friendList.userId == filteredMembers[indexPath.row].friendList.userId {
                    friends[index].isSelected.toggle()
                }
            }
        }
        
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddGroupsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        disableAddGroupButton()
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
        setFilterGroupData()
    }
}
