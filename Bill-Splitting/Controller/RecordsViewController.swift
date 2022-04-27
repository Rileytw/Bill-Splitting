//
//  RecordsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Lottie

class RecordsViewController: UIViewController {
    
    private var animationView = AnimationView()
    var tableView = UITableView()
    var groups: [GroupData] = []
    var itemData: [ItemData] = []
    var paidItem: [ExpenseInfo] = []
    var involvedItem: [ExpenseInfo] = []
    var personalPaid: [ExpenseInfo] = []
    var personalInvolved: [ExpenseInfo] = []
    var allPersonalItem: [ExpenseInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupData()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setAnimation()
//        getGroupData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        animationView.stop()
    }
    // MARK: - Get groups data first
    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: userId, status: 0) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                // MARK: - Use group data to get item data from each group
                self?.getGroupsItemExpense()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }

// MARK: - Get items from all groups
    func getGroupsItemExpense() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "serialQueue", qos: .default, attributes: .concurrent)
        
        queue.async {
            for groupData in self.groups {
                ItemManager.shared.fetchGroupItemData(groupId: groupData.groupId) { [weak self] result in
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
                    ItemManager.shared.fetchPaidItemsExpense(itemId: item.itemId) { [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.paidItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                        }
                    }

                }
            }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
            self.involvedItem.removeAll()
            for index in 0..<self.itemData.count {
                group.enter()
                secondQueue.async(group: group) {
                    ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.itemData[index].itemId) {
                        [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.involvedItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                        }
                    }
                }
            }
        group.notify(queue: DispatchQueue.main) {
            self.personalPaid = self.paidItem.filter { $0.userId == userId }
            self.personalInvolved = self.involvedItem.filter { $0.userId == userId }
            
            for index in 0..<self.personalInvolved.count {
                self.personalInvolved[index].price = 0 - self.personalInvolved[index].price
            }
            print("====involved:\(self.personalInvolved)")
            
            self.allPersonalItem = self.personalPaid + self.personalInvolved
            self.allPersonalItem.sort { $0.createdTime ?? 0 > $1.createdTime ?? 0 }
            self.allPersonalItem = Array(self.allPersonalItem.prefix(10))
//            print("====all:\(self.allPersonalItem)")
//            print("====allCount:\(self.allPersonalItem.count)")
            self.tableView.reloadData()
        }
    }
    
    func setAnimation() {
        animationView = .init(name: "list")
        
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        view.addSubview(animationView)
        animationView.play()
    }
    
    func setTableView() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        tableView.register(UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
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
            itemsCell.createItemCell(time: time,
                                     name: itemName ?? "",
                                     description: PaidDescription.paid,
                                     price: "\(item.price)")
            itemsCell.paidDescription.textColor = .systemGreen
        } else {
            itemsCell.createItemCell(time: time,
                                     name: itemName ?? "",
                                     description: PaidDescription.involved,
                                     price: "\(abs(item.price))")
            itemsCell.paidDescription.textColor = .systemRed
        }
      
        return itemsCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let multipleUsersGroupViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: MultipleUsersGrouplViewController.self)) as? MultipleUsersGrouplViewController else { return }
        
        var personalItem: ItemData?
        var groupData = [GroupData]()
        for items in itemData where items.itemId == allPersonalItem[indexPath.row].itemId {
            personalItem = items
        }
        
        groupData = groups.filter { $0.groupId == personalItem?.groupId }
//        print("peronalitem:\(personalItem)")
        multipleUsersGroupViewController.groupData = groupData[0]
        self.show(multipleUsersGroupViewController, sender: nil)
    }
}
