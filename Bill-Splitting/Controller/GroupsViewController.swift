//
//  GroupsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import SwiftUI

class GroupsViewController: UIViewController {

    let currentUserId = AccountManager.shared.currentUser.currentUserId
    
    let selectedSource = [
        ButtonModel(color: UIColor.hexStringToUIColor(hex: "16C79A"), title: "所有群組"),
        ButtonModel(color: UIColor.hexStringToUIColor(hex: "19456B"), title: "多人支付"),
        ButtonModel(color: UIColor.hexStringToUIColor(hex: "11698E"), title: "個人預付"),
        ButtonModel(color: .systemGray, title: "封存群組")
    ]
    let selectedView = SelectionView(frame: .zero)
    let tableView = UITableView()
    var groups: [GroupData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var multipleGroups: [GroupData] = []
    var personalGroups: [GroupData] = []
    var closedGroups: [GroupData] = []
    var filteredItems: [GroupData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSelectedView()
        setTableView()
        navigationItem.title = "我的群組"
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        tableView.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        setSearchBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
        getClosedGroupData()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: GroupsTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: GroupsTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: currentUserId, status: 0) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func getClosedGroupData() {
        GroupManager.shared.fetchGroups(userId: currentUserId, status: 1) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.closedGroups = groups
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        tableView.tableHeaderView = searchBar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        guard let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton else { return }
        cancelButton.setTitle("取消", for: .normal)
    }
    
    func search(_ searchTerm: String) {
           if searchTerm.isEmpty {
               filteredItems = groups
           } else {
               filteredItems = groups.filter {
                   $0.groupName.contains(searchTerm)
               }
           }
           tableView.reloadData()
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
}

extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedView.buttonIndex == 0 {
            filteredItems = groups
//            return groups.count
        } else if selectedView.buttonIndex == 1 {
            filteredItems = multipleGroups
//            return multipleGroups.count
        } else if selectedView.buttonIndex == 2 {
            filteredItems = personalGroups
//            return personalGroups.count
        } else if selectedView.buttonIndex == 3 {
            filteredItems = closedGroups
//            return closedGroups.count
        } else {
            filteredItems = groups
//            return groups.count
        }
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: GroupsTableViewCell.self),
            for: indexPath
        )
        
        guard let groupsCell = cell as? GroupsTableViewCell else { return cell }
        
        if selectedView.buttonIndex == 0 {
            groupsCell.groupName.text = groups[indexPath.row].groupName
            
            if groups[indexPath.row].type == 1 {
                groupsCell.groupType.text = "多人支付"
            } else {
                groupsCell.groupType.text = "個人預付"
            }
            
            groupsCell.numberOfMembers.text = String(groups[indexPath.row].member.count) + "人"
        } else if selectedView.buttonIndex == 1 {
            groupsCell.groupName.text = multipleGroups[indexPath.row].groupName
            groupsCell.groupType.text = "多人支付"
            groupsCell.numberOfMembers.text = String(multipleGroups[indexPath.row].member.count) + "人"
        } else if selectedView.buttonIndex == 2 {
            groupsCell.groupName.text = personalGroups[indexPath.row].groupName
            groupsCell.groupType.text = "個人預付"
            groupsCell.numberOfMembers.text = String(personalGroups[indexPath.row].member.count) + "人"
        } else if  selectedView.buttonIndex == 3 {
            groupsCell.groupName.text = closedGroups[indexPath.row].groupName
            
            if closedGroups[indexPath.row].type == 1 {
                groupsCell.groupType.text = "多人支付"
            } else {
                groupsCell.groupType.text = "個人預付"
            }
            
            groupsCell.numberOfMembers.text = String(closedGroups[indexPath.row].member.count) + "人"
        } else {
            filteredItems = groups
            
            groupsCell.groupName.text = filteredItems[indexPath.row].groupName

            if filteredItems[indexPath.row].type == 1 {
                groupsCell.groupType.text = "多人支付"
            } else {
                groupsCell.groupType.text = "個人預付"
            }

            groupsCell.numberOfMembers.text = String(filteredItems[indexPath.row].member.count) + "人"
//            groupsCell.groupName.text = groups[indexPath.row].groupName
//
//            if groups[indexPath.row].type == 1 {
//                groupsCell.groupType.text = "多人支付"
//            } else {
//                groupsCell.groupType.text = "個人預付"
//            }
//
//            groupsCell.numberOfMembers.text = String(groups[indexPath.row].member.count) + "人"
        }
        
        groupsCell.backgroundColor = UIColor.hexStringToUIColor(hex: "F8F1F1")
        
        return groupsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let multipleUsersGroupViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: MultipleUsersGrouplViewController.self)) as? MultipleUsersGrouplViewController else { return }
        if selectedView.buttonIndex == 0 {
            multipleUsersGroupViewController.groupData = groups[indexPath.row]
        } else if selectedView.buttonIndex == 1 {
            multipleUsersGroupViewController.groupData = multipleGroups[indexPath.row]
        } else if selectedView.buttonIndex == 2 {
            multipleUsersGroupViewController.groupData = personalGroups[indexPath.row]
        } else if selectedView.buttonIndex == 3 {
            multipleUsersGroupViewController.groupData = closedGroups[indexPath.row]
        } else {
            multipleUsersGroupViewController.groupData = groups[indexPath.row]
        }
//        multipleUsersGroupViewController.groupData = groups[indexPath.row]
        self.show(multipleUsersGroupViewController, sender: nil)
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
            tableView.reloadData()
        } else if selectedView.buttonIndex == 1 {
            multipleGroups = groups.filter { $0.type == GroupType.multipleUsers.typeInt }
            tableView.reloadData()
        } else if selectedView.buttonIndex == 2 {
            personalGroups = groups.filter { $0.type == GroupType.personal.typeInt }
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
}

extension GroupsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true
        let searchTerm = searchBar.text ?? ""
        search(searchTerm)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
