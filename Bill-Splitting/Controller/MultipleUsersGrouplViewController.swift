//
//  MultipleUsersGrouplViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class MultipleUsersGrouplViewController: UIViewController {
    
    let groupDetailView = GroupDetailView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 200))
    let itemTableView = UITableView()
    
    var groupData: GroupData? {
        didSet {
            getItemData()
        }
    }
    var memberName: [String] = []
    var userData: [UserData] = []
    var itemData: [ItemData] = []
    
    var paidItem: [[ExpenseInfo]] = []  {
        didSet {
            itemTableView.reloadData()
        }
    }
    var involvedItem: [[ExpenseInfo]] = []  {
        didSet {
            itemTableView.reloadData()
        }
    }
    
    var expense: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGroupDetailView()
        setItemTableView()
        
//        GroupManager.shared.listenForItems(groupId: groupData?.groupId ?? "") {
//            self.getItemData()
//            print("Listen~~~~~~~~~~~~~~~~~~~")
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groupData?.member.forEach {
            member in
            UserManager.shared.fetchUserData(friendId: member) {
                [weak self] result in
                switch result {
                case .success(let userData):
                    self?.memberName.append(userData.userName)
                    self?.userData.append(userData)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }
        }
    }
    
    func setGroupDetailView() {
        groupDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupDetailView)
        groupDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        groupDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupDetailView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        groupDetailView.addExpenseButton.addTarget(self, action: #selector(pressAddItem), for: .touchUpInside)
    }
    
    @objc func pressAddItem() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddItemViewController.self)) as? AddItemViewController else { return }
        addItemViewController.memberId = groupData?.member
//        addItemViewController.memberName = memberName
        addItemViewController.memberData = userData
        addItemViewController.groupData = groupData
        self.present(addItemViewController, animated: true, completion: nil)
//        self.show(addItemViewController, sender: nil)
    }
    
    func setItemTableView() {
        self.view.addSubview(itemTableView)
        itemTableView.translatesAutoresizingMaskIntoConstraints = false
        itemTableView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 100).isActive = true
        itemTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true

        itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        itemTableView.register(UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        itemTableView.dataSource = self
        itemTableView.delegate = self
    }
    
    func getItemData() {
        ItemManager.shared.fetchGroupItemData(groupId: groupData?.groupId ?? "") {
            [weak self] result in
            switch result {
            case .success(let items):
                self?.itemData = items
                items.forEach {
                    item in
                    self?.getItemDetail(itemId: item.itemId)
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
//        print("=====\(self.paidItem.count)")
//        print("=====\(self.involvedItem.count)")
    }
    
    func getItemDetail(itemId: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "serialQueue", qos: .default, attributes: .concurrent)

        queue.async {
            ItemManager.shared.fetchPaidItemsExpense(itemId: itemId) {
                [weak self] result in
                switch result {
                case .success(let items):
                    self?.paidItem.append(items)
                    semaphore.signal()
                    print("=====[pai\(self?.paidItem)")
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }

            semaphore.wait()

            ItemManager.shared.fetchInvolvedItemsExpense(itemId: itemId) {
                [weak self] result in
                switch result {
                case .success(let items):
                    self?.involvedItem.append(items)
                    print("=====inv\(self?.involvedItem)")
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }
        }
        
//        ItemManager.shared.fetchPaidItemsExpense(itemId: itemId) {
//            [weak self] result in
//            switch result {
//            case .success(let items):
//                self?.paidItem.append(items)
//                print("=====[pai\(self?.paidItem)")
//            case .failure(let error):
//                print("Error decoding userData: \(error)")
//            }
//        }
//        ItemManager.shared.fetchInvolvedItemsExpense(itemId: itemId) {
//            [weak self] result in
//            switch result {
//            case .success(let items):
//                self?.involvedItem.append(items)
//                print("=====inv\(self?.involvedItem)")
//            case .failure(let error):
//                print("Error decoding userData: \(error)")
//            }
//        }
    }
}

extension MultipleUsersGrouplViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return involvedItem.count ?? 0
//        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ItemTableViewCell.self),
            for: indexPath
        )
        
        guard let itemsCell = cell as? ItemTableViewCell else { return cell }

        var item = itemData[indexPath.row]
        var paid = paidItem[indexPath.row][0]
        var involves = involvedItem[indexPath.row]
        
        let timeStamp = item.createdTime ?? 0
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date)
        
//        print("priceeeee:\(paid.price)")
        if paid.userId == userId {
            itemsCell.createItemCell(time: time,
                                     name: item.itemName ?? "",
                                     description: PaidDescription.paid,
                                     price: "\(paid.price)")
        } else {
            for involve in involves {
                if involve.userId == userId {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName ?? "",
                                             description: PaidDescription.involved,
                                             price: "\(involve.price)")
                } else {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName ?? "",
                                             description: PaidDescription.notInvolved,
                                             price: "")
                }
            }
        }
        
//        itemsCell.createItemCell(time: "time",
//                                 name: "itemName",
//                                 description: PaidDescription.paid,
//                                 price: "220")
//
        
        return itemsCell
    }
}
