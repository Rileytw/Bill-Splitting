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
    
    var groups: [GroupData] = []    
    var multipleGroups: [GroupData] = []
    var personalGroups: [GroupData] = []
    var closedGroups: [GroupData] = []
    var filteredGroups: [GroupData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewBackground()
        setSelectedView()
        setTableView()
        navigationItem.title = "我的群組"
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.selectedColor]
//        self.navigationController?.navigationBar.tintColor = UIColor.selectedColor
//        self.navigationController?.navigationBar.backgroundColor = .black
        setSearchBar()
        setAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
        getClosedGroupData()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.backgroundColor = UIColor.clear
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
                self?.setFilterGroupData()
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
                self?.setFilterGroupData()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func setSearchBar() {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        tableView.tableHeaderView = searchBar
        searchBar.barTintColor = UIColor.hexStringToUIColor(hex: "6BA8A9")
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
        animationView = .init(name: "simpleLoading")
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
        } else {
            groupsCell.groupType.text = "個人預付"
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
        self.show(customGroupViewController, sender: nil)
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
