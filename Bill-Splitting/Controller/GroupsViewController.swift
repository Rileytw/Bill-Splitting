//
//  GroupsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class GroupsViewController: UIViewController {

    let groupsView = GroupsView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 80))
    let tableView = UITableView()
    var groups: [GroupData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(groupsView)
        setTableView()
        navigationItem.title = "我的群組"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: groupsView.bottomAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: GroupsTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: GroupsTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: userId) {
            [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
//    func setGroupButton() {
//        view.addSubview(groupsView)
//        
//    }
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: GroupsTableViewCell.self),
            for: indexPath
        )
        
        guard let groupsCell = cell as? GroupsTableViewCell else { return cell }
        
        groupsCell.groupName.text = groups[indexPath.row].groupName
        
        if groups[indexPath.row].type == 1 {
            groupsCell.groupType.text = "多人支付"
        } else {
            groupsCell.groupType.text = "個人預付"
        }
        
        groupsCell.numberOfMembers.text = String(groups[indexPath.row].member.count) + "人"
        
        return groupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let multipleUsersGroupViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: MultipleUsersGrouplViewController.self)) as? MultipleUsersGrouplViewController else { return }
        multipleUsersGroupViewController.groupData = groups[indexPath.row]
        self.show(multipleUsersGroupViewController, sender: nil)
    }
}
