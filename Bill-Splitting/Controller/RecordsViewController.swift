//
//  RecordsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit

class RecordsViewController: BaseViewController {
    
// MARK: - Property
    var tableView = UITableView()
    var emptyLabel = UILabel()
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var groups: [GroupData] = []
    var itemData: [ItemData] = []
    var paidItem: [ExpenseInfo] = []
    var involvedItem: [ExpenseInfo] = []
    var personalPaid: [ExpenseInfo] = []
    var personalInvolved: [ExpenseInfo] = []
    var allPersonalItem: [ExpenseInfo] = []

// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setEmptyLabel()
        setTableView()
        setAnimation()
        navigationItem.title = NavigationItemName.records.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGroupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanData()
    }

// MARK: - Method
    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: currentUserId, status: 0) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                // MARK: - Use group data to get item data from each group
                self?.getGroupsItemExpense()
                if groups.isEmpty == true {
                    self?.emptyLabel.isHidden = false
                } else {
                    self?.emptyLabel.isHidden = true
                }
            case .failure:
                self?.showFailure(text: ErrorType.dataFetchError.errorMessage)
            }
        }
    }

// MARK: - Get items from all groups
    func getGroupsItemExpense() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "serialQueue", qos: .default, attributes: .concurrent)
        
        queue.async {
            for groupData in self.groups {
                ItemManager.shared.listenGroupItemData(groupId: groupData.groupId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.itemData += items
                        semaphore.signal()
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        
                    }
                }
                semaphore.wait()
            }
            self.getItemExpense()
        }
    }
    
    // MARK: - Use GCD group to get two collection data at same time
    func getItemExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
            self.paidItem.removeAll()
            for item in self.itemData {
                group.enter()
                firstQueue.async(group: group) {
                    ItemManager.shared.fetchPaidItemExpense(itemId: item.itemId) { [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.paidItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                            group.leave()
                        }
                    }

                }
            }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
            self.involvedItem.removeAll()
            for index in 0..<self.itemData.count {
                group.enter()
                secondQueue.async(group: group) {
                    ItemManager.shared.fetchInvolvedItemExpense(itemId: self.itemData[index].itemId) { [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.involvedItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                            group.leave()
                        }
                    }
                }
            }
        group.notify(queue: DispatchQueue.main) {
            self.personalPaid = self.paidItem.filter { $0.userId == self.currentUserId }
            self.personalInvolved = self.involvedItem.filter { $0.userId == self.currentUserId }
            
            for index in 0..<self.personalInvolved.count {
                self.personalInvolved[index].price = 0 - self.personalInvolved[index].price
            }
            
            self.allPersonalItem = self.personalPaid + self.personalInvolved
            self.allPersonalItem.sort { $0.createdTime ?? 0 > $1.createdTime ?? 0 }
            self.allPersonalItem = Array(self.allPersonalItem.prefix(10))
            self.tableView.reloadData()
            self.removeAnimation()
        }
    }

    func cleanData() {
        groups.removeAll()
        itemData.removeAll()
        paidItem.removeAll()
        involvedItem.removeAll()
        personalPaid.removeAll()
        personalInvolved.removeAll()
        allPersonalItem.removeAll()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        tableView.register(UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil),
                           forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.text = "目前暫無資料"
        emptyLabel.textColor = .greenWhite
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emptyLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        emptyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        emptyLabel.isHidden = true
    }
}

extension RecordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPersonalItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ItemTableViewCell.self),
            for: indexPath
        )
        
        guard let itemsCell = cell as? ItemTableViewCell else { return cell }
        
        let item = allPersonalItem[indexPath.row]
        
        let timeStamp = item.createdTime
        let timeInterval = TimeInterval(timeStamp ?? 0)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date)
        
        var itemName: String?
        for items in itemData where items.itemId == item.itemId {
            itemName = items.itemName
        }
        
        if item.price > 0 {
            if itemName == "結帳" {
                itemsCell.createItemCell(time: time,
                                         name: itemName ?? "",
                                         description: PaidDescription.settleUpInvolved,
                                         price: item.price)
                itemsCell.paidDescription.textColor = .styleRed
            } else {
                itemsCell.createItemCell(time: time,
                                         name: itemName ?? "",
                                         description: PaidDescription.paid,
                                         price: item.price)
                itemsCell.paidDescription.textColor = .styleGreen
            }
        } else {
            if itemName == "結帳" {
                itemsCell.createItemCell(time: time,
                                         name: itemName ?? "",
                                         description: PaidDescription.settleUpPaid,
                                         price: abs(item.price))
                itemsCell.paidDescription.textColor = .styleGreen
            } else {
                itemsCell.createItemCell(time: time,
                                         name: itemName ?? "",
                                         description: PaidDescription.involved,
                                         price: abs(item.price))
                itemsCell.paidDescription.textColor = .styleRed
            }
        }
      
        return itemsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let customGroupViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: CustomGroupViewController.self)) as? CustomGroupViewController else { return }
        
        var personalItem: ItemData?
        var groupData: GroupData?
        for items in itemData where items.itemId == allPersonalItem[indexPath.row].itemId {
            personalItem = items
        }
        
        groupData = groups.first(where: { $0.groupId == personalItem?.groupId })
        customGroupViewController.group = groupData
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
