//
//  ViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/8.
//

import UIKit

class AddGroupsViewController: UIViewController {
    
    var nameTextField = UITextField()
    let descriptionTextView = UITextView()
    
    let fullScreenSize = UIScreen.main.bounds.size
    var typeTextField = UITextField()
    
    var pickerView: UIPickerView!
    var pickerViewData = ["個人預付", "多人支付"]
    
    var friendList: [Friend]? {
        didSet {
            tableView.reloadData()
        }
    }
    var selectedIndexs = [Int]()
    
    let tableView = UITableView()
    var searchController: UISearchController!
    
    let inviteFriendButton = UIButton()
    let addGroupButton = UIButton()
    
    var type: Int?
    
    var member: [String] = []
    
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
//        disableAddGroupButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UserManager.shared.fetchFriendData(userId: userId) { [weak self] result in
            switch result {
            case .success(let friend):
                self?.friendList = friend
//                print("userData: \(self.friendList)")
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
        disableAddGroupButton()
    }
    
    func setTextField() {
        nameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        nameTextField.layer.borderColor = UIColor.black.cgColor
        nameTextField.layer.borderWidth = 1
        self.view.addSubview(nameTextField)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameTextField, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
        
        let nameLabel = UILabel()
        nameLabel.text = "群組名稱"
        view.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 100).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: nameLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 40).isActive = true
    }
    
    func setTextView() {
        descriptionTextView.layer.borderWidth = 1
        self.view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionTextView, attribute: .top, relatedBy: .equal, toItem: nameTextField, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: descriptionTextView,attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: (UIScreen.main.bounds.width)/3).isActive = true
        
        NSLayoutConstraint(item: descriptionTextView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "群組簡介"
        view.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: nameTextField, attribute: .top, multiplier: 1, constant: 50).isActive = true
        NSLayoutConstraint(item: descriptionLabel,attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20).isActive = true
        
        NSLayoutConstraint(item: descriptionLabel, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 2/3, constant: -20).isActive = true
        NSLayoutConstraint(item: descriptionLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100).isActive = true
    }
    
    func setUpPickerView(data:[String]) {
        pickerViewData = data
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func setTextFieldOfPickerView() {
        typeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 60))
        typeTextField.inputView = pickerView
        typeTextField.text = pickerViewData[0]
        typeTextField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        typeTextField.textAlignment = .center
        self.view.addSubview(typeTextField)
        typeTextField.translatesAutoresizingMaskIntoConstraints = false
        typeTextField.widthAnchor.constraint(equalToConstant: fullScreenSize.width).isActive = true
        typeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        typeTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 40).isActive = true
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
        inviteFriendButton.backgroundColor = .systemGray
        view.addSubview(inviteFriendButton)
        inviteFriendButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        inviteFriendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        inviteFriendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        inviteFriendButton.bottomAnchor.constraint(equalTo: addGroupButton.topAnchor, constant: -20).isActive = true
        
        inviteFriendButton.addTarget(self, action: #selector(pressInviteFriendButton), for: .touchUpInside)
    }
    
    func setAddGroupButton() {
        addGroupButton.setTitle("建立群組", for: .normal)
        addGroupButton.backgroundColor = .systemGray
        view.addSubview(addGroupButton)
        addGroupButton.translatesAutoresizingMaskIntoConstraints = false
        addGroupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addGroupButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60).isActive = true
        addGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60).isActive = true
        addGroupButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
        addGroupButton.addTarget(self, action: #selector(pressAddGroupButton), for: .touchUpInside)
    }
    
    @objc func pressAddGroupButton() {
        print("member:\(self.member)")
        member.append(userId)
        
        if typeTextField.text == "個人預付" {
            type = 0
        } else {
            type = 1
        }
        
        GroupManager.shared.addGroupData(name: nameTextField.text ?? "", description: descriptionTextView.text, creator: userId, type: self.type ?? 0, status: 0, member: self.member ?? [""]) {
            groupId in
            self.member.forEach {
                member in
                GroupManager.shared.addMemberExpenseData(userId: member, allExpense: 0, groupId: groupId)
            }
        }
        
        self.nameTextField.text? = ""
        self.descriptionTextView.text = ""
        self.typeTextField.text = "個人預付"
        self.selectedIndexs.removeAll()
        self.tableView.reloadData()
        self.member.removeAll()
    }
    
    @objc func pressInviteFriendButton() {
        let storyBoard = UIStoryboard(name: "AddGroups", bundle: nil)
        let inviteFriendViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: InviteFriendViewController.self))
        self.present(inviteFriendViewController, animated: true, completion: nil)
    }
    
    func disableAddGroupButton() {
        if nameTextField.text?.isEmpty == true {
            addGroupButton.isEnabled = false
            addGroupButton.backgroundColor = .systemGray2
        } else {
            addGroupButton.isEnabled = true
            addGroupButton.backgroundColor = .systemGray
        }
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
        return friendList?.count ?? 0
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
        
        addGroupsCell.friendNameLabel.text = friendList?[indexPath.row].userName
        if selectedIndexs.contains(indexPath.row) {
            cell.accessoryType = .checkmark
            addGroupsCell.selectedButton.isSelected = true
        } else {
            cell.accessoryType = .none
            addGroupsCell.selectedButton.isSelected = false
        }
        
        return addGroupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let index = selectedIndexs.index(of: indexPath.row) {
            selectedIndexs.remove(at: index)
//            print(selectedIndexs)
            member.remove(at: index)
        } else {
            selectedIndexs.append(indexPath.row)
            member.append(friendList?[indexPath.row].userId ?? "")
//            print(selectedIndexs)
        }
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

extension AddGroupsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        disableAddGroupButton()
    }
}
