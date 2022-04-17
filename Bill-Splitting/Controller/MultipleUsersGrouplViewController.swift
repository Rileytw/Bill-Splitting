//
//  MultipleUsersGrouplViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class MultipleUsersGrouplViewController: UIViewController {
    
    let groupDetailView = GroupDetailView(frame: .zero)
    let itemTableView = UITableView()
    
    var groupData: GroupData?
    
    var memberName: [String] = []
    var userData: [UserData] = []
    var itemData: [ItemData] = []
    
    var paidItem: [[ExpenseInfo]] = [] {
        didSet {
            itemTableView.reloadData()
        }
    }
    var involvedItem: [[ExpenseInfo]] = [] {
        didSet {
            itemTableView.reloadData()
        }
    }
    
    var expense: Double? {
        didSet {
            if expense ?? 0 >= 0 {
                groupDetailView.personalFinalPaidLabel.text = "你的總支出為：\(expense ?? 0) 元"
            } else {
                groupDetailView.personalFinalPaidLabel.text = "你的總欠款為：\(abs(expense ?? 0)) 元"
            }
        }
    }
    
    var memberExpense: [MemberExpense] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getItemData()
        setGroupDetailView()
        setItemTableView()
        getMemberExpense()
        
        navigationItem.title = "群組"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func getUserData() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "Queue", qos: .default, attributes: .concurrent)
        
        queue.async {
            self.groupData?.member.forEach {
                member in
                UserManager.shared.fetchUserData(friendId: member) {
                    [weak self] result in
                    switch result {
                    case .success(let userData):
                        self?.memberName.append(userData.userName)
                        self?.userData.append(userData)
                        semaphore.signal()
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        semaphore.signal()
                    }
                }
                semaphore.wait()
            }
        }
        
    }
    
    func setGroupDetailView() {
        groupDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupDetailView)
        groupDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        groupDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupDetailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        groupDetailView.addExpenseButton.addTarget(self, action: #selector(pressAddItem), for: .touchUpInside)
        groupDetailView.settleUpButton.addTarget(self, action: #selector(pressSettleUp), for: .touchUpInside)
        
        groupDetailView.personalFinalPaidLabel.text = "你的總支出為："
        detectParticipantUser()
    }
    
    @objc func pressAddItem() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddItemViewController.self)) as? AddItemViewController else { return }
        addItemViewController.memberId = groupData?.member
        addItemViewController.memberData = userData
        addItemViewController.groupData = groupData
        self.present(addItemViewController, animated: true, completion: nil)
        //        self.show(addItemViewController, sender: nil)
        
        addItemViewController.addItem { [weak self] _ in
            self?.getItemData()
            self?.getMemberExpense()
        }
    }
    
    @objc func pressSettleUp() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let settleUpViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: SettleUpViewController.self)) as? SettleUpViewController else { return }
        
        settleUpViewController.groupData = groupData
        settleUpViewController.memberExpense = memberExpense
        settleUpViewController.userData = userData
        settleUpViewController.expense = expense
        self.show(settleUpViewController, sender: nil)
    }
    
    func setItemTableView() {
        self.view.addSubview(itemTableView)
        itemTableView.translatesAutoresizingMaskIntoConstraints = false
        itemTableView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 40).isActive = true
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
                    //                    print("=====[pai\(self?.paidItem)")
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
//                    print("=====inv\(self?.involvedItem)")
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }
        }
    }
    
    func getMemberExpense() {
        GroupManager.shared.fetchMemberExpense(groupId: groupData?.groupId ?? "", userId: userId) { [weak self] result in
            switch result {
            case .success(let expense):
                self?.memberExpense = expense
                let personalExpense = expense.filter { $0.userId == userId }
                self?.expense = personalExpense[0].allExpense
                //                print("=====expense:\(self?.memberExpense)")
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func detectParticipantUser() {
        if groupData?.type == 0 && userId != groupData?.creator {
            groupDetailView.addExpenseButton.isEnabled = false
            groupDetailView.addExpenseButton.isHidden = true
        }
    }
}

extension MultipleUsersGrouplViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return involvedItem.count
        //        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ItemTableViewCell.self),
            for: indexPath
        )
        
        guard let itemsCell = cell as? ItemTableViewCell else { return cell }
        
        let item = itemData[indexPath.row]
        var paid: ExpenseInfo?
        for index in 0..<paidItem.count {
            if paidItem[index][0].itemId == item.itemId {
                paid = paidItem[index][0]
                break
            }
        }
        var involves = [ExpenseInfo]()
        var involved: ExpenseInfo?
        for index in 0..<involvedItem.count {
            involves = involvedItem[index]
            for involve in  0..<involves.count {
                if involves[involve].itemId == item.itemId && involves[involve].userId == userId {
                    involved = involves[involve]
                    print("===involved:\(involved)")
                    break
                }
            }
        }
        
        let timeStamp = item.createdTime
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date)
        
        if paid?.userId == userId {
            itemsCell.createItemCell(time: time,
                                     name: item.itemName,
                                     description: PaidDescription.paid,
                                     price: "$\(paid?.price ?? 0)")
            itemsCell.paidDescription.textColor = .systemGreen
        } else {
            if involved?.userId == userId {
            itemsCell.createItemCell(time: time,
                                     name: item.itemName,
                                     description: PaidDescription.involved,
                                     price: "$\(involved?.price ?? 0)")
                itemsCell.paidDescription.textColor = .systemRed
            } else {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.notInvolved,
                                         price: "")
                itemsCell.paidDescription.textColor = .systemGray
            }
        }
        return itemsCell
    }
}
