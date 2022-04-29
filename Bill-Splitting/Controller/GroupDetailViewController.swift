//
//  GroupDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class GroupDetailViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var tableView = UITableView()
    var editButton = UIButton()
    var groupData: GroupData?
    var userData: [UserData] = []
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        setButton()
        setAddGroupButton()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.register(UINib(nibName: String(describing: GroupDetailTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: GroupDetailTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: InvitationTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: InvitationTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setButton() {
        view.addSubview(editButton)
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        editButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        editButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        editButton.setTitle("編輯群組資訊", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.tintColor = .systemBlue
        editButton.contentHorizontalAlignment = .right
        editButton.addTarget(self, action: #selector(pressEdit), for: .touchUpInside)
        
        if groupData?.creator != currentUserId {
            editButton.isHidden = true
        }
    }
    
    @objc func pressEdit() {
        let storyBoard = UIStoryboard(name: "AddGroups", bundle: nil)
        guard let addGroupViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddGroupsViewController.self)) as? AddGroupsViewController else { return }
        addGroupViewController.isGroupExist = true
        addGroupViewController.groupData = groupData
//        self.present(addGroupViewController, animated: true, completion: nil)
        self.show(addGroupViewController, sender: nil)
    }
    
    func setAddGroupButton() {
        let addButton = UIBarButtonItem.init(title: "編輯", style: UIBarButtonItem.Style.plain, target: self, action: #selector(pressEdit))
        self.navigationItem.setRightBarButton(addButton, animated: true)
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
                withIdentifier: String(describing: InvitationTableViewCell.self),
                for: indexPath
            )
            guard let memberCell = cell as? InvitationTableViewCell else { return cell }
            
            memberCell.agreeButton.isHidden = true
            memberCell.disagreeButton.isHidden = true
            
            var memberData = [UserData]()
            
            for index in 0..<groupData.member.count {
                memberData += userData.filter { $0.userId == groupData.member[index] }
            }
            
            memberCell.nameLabel.text = memberData[indexPath.row].userName
            memberCell.email.text = memberData[indexPath.row].userEmail
            
            return memberCell
        }
    }
}
