//
//  GroupDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class GroupDetailViewController: UIViewController {

    var tableView = UITableView()
    var groupData: GroupData?
    var userData: [UserData] = []
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.register(UINib(nibName: String(describing: GroupDetailTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: GroupDetailTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: InvitationTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: InvitationTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
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
                                        content: groupData.goupDescription,
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
            
            return memberCell
        }
    }
}
