//
//  MultipleUsersGrouplViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import Lottie

class CustomGroupViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let groupDetailView = GroupDetailView(frame: .zero)
    let itemTableView = UITableView()
    let closedGroupButton = UIButton()
    let subscribeButton = UIButton()
    let groupName = UILabel()
    let width = UIScreen.main.bounds.width
    private var animationView = AnimationView()
    
    var groupData: GroupData?
    
    var memberName: [String] = []
    var userData: [UserData] = []
    var leaveMemberData: [UserData] = []
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
    
    var subscriptInvolvedItem: [SubscriptionMember] = []
    
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
    
    var subsriptions: [Subscription] = []
    var subscriptionCreatedTime: Double?
    
    var blackList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setGroupNameLabel()
        setGroupDetailView()
        setClosedGroupButton()
        setItemTableView()
        setSubscribeButton()
        detectSubscription()
        addMenu()
        setAnimation()
        navigationItem.title = "群組"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        userData.removeAll()
        leaveMemberData.removeAll()
        
        getItemData()
        getMemberExpense()
        getLeaveMemberData()
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
        groupData?.member.forEach { member in
            UserManager.shared.fetchUserData(friendId: member) { [weak self] result in
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
    
    func getLeaveMemberData() {
        if groupData?.leaveMembers != nil {
            groupData?.leaveMembers?.forEach { member in
                UserManager.shared.fetchUserData(friendId: member) { [weak self] result in
                    switch result {
                    case .success(let userData):
                        self?.leaveMemberData.append(userData)
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                    }
                }
            }
        }
    }
    
    func setGroupDetailView() {
        groupDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupDetailView)
        groupDetailView.topAnchor.constraint(equalTo: groupName.bottomAnchor, constant: 5).isActive = true
        groupDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupDetailView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        groupDetailView.addExpenseButton.addTarget(self, action: #selector(pressAddItem), for: .touchUpInside)
        groupDetailView.chartButton.addTarget(self, action: #selector(pressChartButton), for: .touchUpInside)
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
    }
    
    @objc func pressChartButton() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let chartViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: ChartViewController.self)) as? ChartViewController else { return }
        chartViewController.memberExpense = memberExpense
        chartViewController.userData = userData
        chartViewController.modalPresentationStyle = .fullScreen
        self.present(chartViewController, animated: true, completion: nil)
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
        itemTableView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 10).isActive = true
        itemTableView.bottomAnchor.constraint(equalTo: closedGroupButton.topAnchor, constant: -10).isActive = true
        itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        itemTableView.register(UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        itemTableView.dataSource = self
        itemTableView.delegate = self
        
        itemTableView.backgroundColor = UIColor.clear
    }
    
    func setClosedGroupButton() {
        view.addSubview(closedGroupButton)
        closedGroupButton.translatesAutoresizingMaskIntoConstraints = false
        closedGroupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        closedGroupButton.widthAnchor.constraint(equalToConstant: width/3 - 10).isActive = true
        closedGroupButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        closedGroupButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        closedGroupButton.setTitle("封存群組", for: .normal)
        closedGroupButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        closedGroupButton.tintColor = .greenWhite
        closedGroupButton.setTitleColor(.greenWhite, for: .normal)
        closedGroupButton.addTarget(self, action: #selector(confirmCloseGroupAlert), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(closedGroupButton)
    }
    
    func pressClosedGroup() {
        GroupManager.shared.updateGroupStatus(groupId: groupData?.groupId ?? "")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func confirmCloseGroupAlert() {
        let alertController = UIAlertController(title: "請確認使否封存群組", message: "封存後群組內容將不可編輯", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "封存", style: .destructive) { [weak self] _ in
            self?.pressClosedGroup()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setSubscribeButton() {
        view.addSubview(subscribeButton)
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        subscribeButton.widthAnchor.constraint(equalToConstant: width/3 - 10).isActive = true
        subscribeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        
        if groupData?.type == 1 {
            subscribeButton.isHidden = true
        } else if groupData?.type == 0 && groupData?.creator != currentUserId {
            subscribeButton.isHidden = true
        }
        
        subscribeButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        subscribeButton.setTitle("設定週期", for: .normal)
        subscribeButton.tintColor = .greenWhite
        subscribeButton.setTitleColor(.greenWhite, for: .normal)
        subscribeButton.addTarget(self, action: #selector(pressSubscribe), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(subscribeButton)
    }
    
    @objc func pressSubscribe() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let subscribeViewController =
                storyBoard.instantiateViewController(withIdentifier: String(describing: SubscribeViewController.self)) as? SubscribeViewController else { return }
        subscribeViewController.memberId = groupData?.member
        subscribeViewController.memberData = userData
        subscribeViewController.groupData = groupData
        self.present(subscribeViewController, animated: true, completion: nil)
    }
    
    func getItemData() {
        ItemManager.shared.fetchGroupItemData(groupId: groupData?.groupId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                if items.isEmpty == true {
                    self?.removeAnimation()
                }
                self?.itemData = items
                items.forEach { item in
                    self?.getItemDetail(itemId: item.itemId)
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func getItemDetail(itemId: String) {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "serialQueue", qos: .default, attributes: .concurrent)
        
        queue.async {
            ItemManager.shared.fetchPaidItemsExpense(itemId: itemId) { [weak self] result in
                switch result {
                case .success(let items):
                    self?.paidItem.append(items)
                    semaphore.signal()
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
            
            ItemManager.shared.fetchInvolvedItemsExpense(itemId: itemId) { [weak self] result in
                switch result {
                case .success(let items):
                    self?.involvedItem.append(items)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
                self?.removeAnimation()
            }
        }
    }

// MARK: - Bugs of new user get into groups, can't fetch data
    func getMemberExpense() {
        GroupManager.shared.fetchMemberExpense(groupId: groupData?.groupId ?? "", members: groupData?.member ?? []) { [weak self] result in
            switch result {
            case .success(let expense):
                self?.memberExpense = expense
                let personalExpense = expense.filter { $0.userId == (self?.currentUserId ?? "") }
                self?.expense = personalExpense[0].allExpense
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func detectParticipantUser() {
        if groupData?.type == 0 && currentUserId != groupData?.creator {
            groupDetailView.addExpenseButton.isEnabled = false
            groupDetailView.addExpenseButton.isHidden = true
            closedGroupButton.isHidden = true
        }
    }
    
    func detectSubscription() {
        let nowTime = Date().timeIntervalSince1970
        if groupData?.type == 0 {
            SubscriptionManager.shared.fetchSubscriptionData(groupId: groupData?.groupId ?? "") { [weak self] result  in
                switch result {
                case .success(let subscription):
                    self?.subsriptions = subscription
                    if (self?.subsriptions.count != 0) && subscription[0].startTime <= nowTime {
                        self?.countSubscriptiontime()
                        self?.subscriptionCreatedTime = subscription[0].startTime
                        SubscriptionManager.shared.updateSubscriptionData(documentId: subscription[0].doucmentId,
                                                                          newStartTime: self?.subsriptions[0].startTime ?? 0)
                        SubscriptionManager.shared.fetchSubscriptionInvolvedData(documentId: subscription[0].doucmentId) {
                            [weak self] result in
                            switch result {
                            case .success(let subscriptionMember):
                                self?.subscriptInvolvedItem = subscriptionMember
                                self?.addSubscriptionItem()
                            case .failure(let error):
                                print("Error decoding userData: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }
        }
    }
    
    func countSubscriptiontime() {
        let startTime = subsriptions[0].startTime
        let endTime = subsriptions[0].endTime
        let startTimeInterval = TimeInterval(startTime)
        let endTimeInterval = TimeInterval(endTime)
        var startDate = Date(timeIntervalSince1970: startTimeInterval)
        let endDate = Date(timeIntervalSince1970: endTimeInterval)
        
        switch subsriptions[0].cycle {
        case 0 :
            let components = Calendar.current.dateComponents([.month], from: startDate, to: endDate)
            let month = components.month
            if month ?? 0 > 1 {
                var dateComponent = DateComponents()
                dateComponent.month = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
                subsriptions[0].startTime = startDate.timeIntervalSince1970
            } else {
                SubscriptionManager.shared.deleteSubscriptionDocument(documentId: subsriptions[0].doucmentId)
            }
        case 1 :
            let components = Calendar.current.dateComponents([.year], from: startDate, to: endDate)
            let year = components.year
            if year ?? 0 > 1 {
                var dateComponent = DateComponents()
                dateComponent.year = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
                subsriptions[0].startTime = startDate.timeIntervalSince1970
            } else {
                SubscriptionManager.shared.deleteSubscriptionDocument(documentId: subsriptions[0].doucmentId)
            }
        default:
            return
        }
    }
    
    func addSubscriptionItem() {
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "",
                                       itemName: subsriptions[0].itemName ?? "",
                                       itemDescription: "",
                                       createdTime: self.subscriptionCreatedTime ?? 0,
                                       itemImage: nil) { itemId in
            var paidUserId: String?
            paidUserId = self.subsriptions[0].paidUser
            
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                           price: self.subsriptions[0].paidPrice ?? 0,
                                           itemId: itemId,
                                           createdTime: self.subscriptionCreatedTime ?? 0)
            
            for user in 0..<self.subscriptInvolvedItem.count {
                ItemManager.shared.addInvolvedInfo(involvedUserId: self.subscriptInvolvedItem[user].involvedUser,
                                                   price: self.subscriptInvolvedItem[user].involvedPrice,
                                                   itemId: itemId,
                                                   createdTime: self.subscriptionCreatedTime ?? 0)
            }
            self.countPersonalExpense()
        }
    }
    
    func countPersonalExpense() {
        var paidUserId: String?
        paidUserId = subsriptions[0].paidUser
        GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                newExpense: self.subsriptions[0].paidPrice,
                                                groupId: groupData?.groupId ?? "")
        
        for user in 0..<self.subscriptInvolvedItem.count {
            GroupManager.shared.updateMemberExpense(userId: self.subscriptInvolvedItem[user].involvedUser,
                                                    newExpense: 0 - self.subscriptInvolvedItem[user].involvedPrice,
                                                    groupId: groupData?.groupId ?? "")
        }
    }
    
    func addMenu() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        let interaction = UIContextMenuInteraction(delegate: self)
        button.addInteraction(interaction)
    }
    
    func setGroupNameLabel() {
        view.addSubview(groupName)
        groupName.translatesAutoresizingMaskIntoConstraints = false
        groupName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        groupName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        groupName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10).isActive = true
        groupName.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        groupName.textColor = .greenWhite
        groupName.text = groupData?.groupName ?? ""
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

extension CustomGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemData.count
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
                if involves[involve].itemId == item.itemId && involves[involve].userId == currentUserId {
                    involved = involves[involve]
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
        
        if paid?.userId == currentUserId {
            
            if item.itemName == "結帳" {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.settleUpInvolved,
                                         price: "$\(paid?.price ?? 0)")
                itemsCell.paidDescription.textColor = UIColor.styleGreen
            } else {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.paid,
                                         price: "$\(paid?.price ?? 0)")
                itemsCell.paidDescription.textColor = UIColor.styleGreen
            }
        } else {
            if involved?.userId == currentUserId {
                if item.itemName == "結帳" {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName,
                                             description: PaidDescription.settleUpPaid,
                                             price: "$\(involved?.price ?? 0)")
                    itemsCell.paidDescription.textColor = UIColor.styleRed
                } else {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName,
                                             description: PaidDescription.involved,
                                             price: "$\(involved?.price ?? 0)")
                    itemsCell.paidDescription.textColor = UIColor.styleRed
                }
            } else {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.notInvolved,
                                         price: "")
                itemsCell.paidDescription.textColor = UIColor.greenWhite
            }
        }
        return itemsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let itemDetailViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: ItemDetailViewController.self)) as? ItemDetailViewController else { return }
        
        let item = itemData[indexPath.row]
        itemDetailViewController.itemId = item.itemId
        itemDetailViewController.userData = userData
        itemDetailViewController.groupData = groupData
        itemDetailViewController.leaveMemberData = leaveMemberData
        
        self.show(itemDetailViewController, sender: nil)
        
    }
}

extension CustomGroupViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
           
            let infoAction = UIAction(title: "查看群組資訊", image: UIImage(systemName: "eye")) { action in
                print("eeeee")
                let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
                guard let detailViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: GroupDetailViewController.self)) as? GroupDetailViewController else { return }
                detailViewController.groupData = self.groupData
                detailViewController.userData = self.userData
                detailViewController.personalExpense = self.expense
//                self.present(detailViewController, animated: true, completion: nil)
                self.show(detailViewController, sender: nil)
            }

            return UIMenu(title: "", children: [infoAction])
        }
    }
}
