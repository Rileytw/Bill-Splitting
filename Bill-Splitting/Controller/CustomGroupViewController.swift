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
    let subscribeButton = UIButton()
    let width = UIScreen.main.bounds.width
    private var animationView = AnimationView()
    var noDataView = NoDataView(frame: .zero)
    
    var reportView = ReportView()
    var mask = UIView()
    let height = UIScreen.main.bounds.size.height
    var reportContent: String?
    
    var groupData: GroupData?
    
    var memberName: [String] = []
    var userData: [UserData] = []
    var leaveMemberData: [UserData] = []
    var itemData: [ItemData] = []
    var item: ItemData?
    
    var paidItem: [[ExpenseInfo]] = []
    var involvedItem: [[ExpenseInfo]] = []

    
    var subscriptInvolvedItem: [SubscriptionMember] = []
    
    var expense: Double? {
        didSet {
            if expense ?? 0 >= 0 {
                let revealExpense = String(format: "%.2f", expense ?? 0)
                groupDetailView.personalFinalPaidLabel.text = "你的總支出為：\(revealExpense) 元"
            } else {
                let revealExpense = String(format: "%.2f", abs(expense ?? 0))
                groupDetailView.personalFinalPaidLabel.text = "你的總欠款為：\(revealExpense) 元"
            }
        }
    }
    
    var memberExpense: [MemberExpense] = []
    var allExpense: Double = 0
    
    var subsriptions: [Subscription] = []
    var subscriptionCreatedTime: Double?
    
    var blackList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        setGroupDetailView()
        setNoDataView()
        setItemTableView()
        setSubscribeButton()
        detectSubscription()
        addMenu()
        setAnimation()
        navigationItem.title = "群組"
        getItemData()
        getMemberExpense()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        userData.removeAll()
        leaveMemberData.removeAll()
        
//        getItemData()
//        getMemberExpense()
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
                    self?.memberName.append(userData?.userName ?? "")
                    if let userData = userData {
                        self?.userData.append(userData)
                    }
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
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
                        if let userData = userData {
                            self?.leaveMemberData.append(userData)
                        }
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        ProgressHUD.shared.view = self?.view ?? UIView()
                        ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                    }
                }
            }
        }
    }
    
    func setGroupDetailView() {
        groupDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(groupDetailView)
        groupDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        groupDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupDetailView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        groupDetailView.groupName.text = groupData?.groupName ?? ""
        groupDetailView.addExpenseButton.addTarget(self, action: #selector(pressAddItem), for: .touchUpInside)
        groupDetailView.chartButton.addTarget(self, action: #selector(pressChartButton), for: .touchUpInside)
        groupDetailView.settleUpButton.addTarget(self, action: #selector(pressSettleUp), for: .touchUpInside)
        
        groupDetailView.personalFinalPaidLabel.text = "你的總支出為："
        detectParticipantUser()
    }
    
    @objc func pressAddItem() {
        if groupData?.status == GroupStatus.active.typeInt {
            let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
            guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddItemViewController.self)) as? AddItemViewController else { return }
            addItemViewController.memberId = groupData?.member
            addItemViewController.memberData = userData
            addItemViewController.groupData = groupData
            addItemViewController.blackList = blackList
            self.present(addItemViewController, animated: true, completion: nil)
        } else {
            addItemAlert()
        }
    }
    
    @objc func pressChartButton() {
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let chartViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: ChartViewController.self)) as? ChartViewController else { return }
        chartViewController.memberExpense = memberExpense
        chartViewController.userData = userData
        chartViewController.blackList = blackList
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
        settleUpViewController.blackList = blackList
        settleUpViewController.leaveMemberData = leaveMemberData
        self.show(settleUpViewController, sender: nil)
    }
    
    func setItemTableView() {
        self.view.addSubview(itemTableView)
        itemTableView.translatesAutoresizingMaskIntoConstraints = false
        itemTableView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 10).isActive = true
        itemTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        itemTableView.register(UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        itemTableView.dataSource = self
        itemTableView.delegate = self
        
        itemTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        itemTableView.backgroundColor = UIColor.clear
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        itemTableView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: itemTableView)
            if let indexPath = itemTableView.indexPathForRow(at: touchPoint) {
                item = itemData[indexPath.row]
                revealBlockView()
            }
        }
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
    
    func disableCloseGroup() {
        let alertController = UIAlertController(title: "群組已封存", message: "不可重複封存群組", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "確認", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setSubscribeButton() {
        view.addSubview(subscribeButton)
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
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
        subscribeViewController.blackList = blackList
        self.present(subscribeViewController, animated: true, completion: nil)
    }
    
    func getItemData() {
        ItemManager.shared.fetchGroupItemData(groupId: groupData?.groupId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                if items.isEmpty == true {
                    self?.removeAnimation()
                    self?.noDataView.noDataLabel.isHidden = false
                } else {
                    self?.noDataView.noDataLabel.isHidden = true
                }
                self?.itemData = items
                items.forEach { item in
                    self?.getItemDetail(itemId: item.itemId)
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
            }
        }
    }
    
    func getItemDetail(itemId: String) {
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        
        firstQueue.async(group: group) {
            ItemManager.shared.fetchPaidItemsExpense(itemId: itemId) { [weak self] result in
                switch result {
                case .success(let items):
                    self?.paidItem.append(items)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                    
                }
                group.leave()
            }
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        secondQueue.async(group: group) {
            ItemManager.shared.fetchInvolvedItemsExpense(itemId: itemId) { [weak self] result in
                switch result {
                case .success(let items):
                    self?.involvedItem.append(items)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                }
                group.leave()
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.itemTableView.reloadData()
            self.removeAnimation()
        }
    }

// MARK: - Bugs of new user get into groups, can't fetch data
    func getMemberExpense() {
        GroupManager.shared.fetchMemberExpense(groupId: groupData?.groupId ?? "", members: groupData?.member ?? []) { [weak self] result in
            switch result {
            case .success(let expense):
                self?.memberExpense = expense
                let personalExpense = expense.filter { $0.userId == (self?.currentUserId ?? "") }
                if personalExpense.isEmpty == false {
                    self?.expense = personalExpense[0].allExpense
                }
                let allExpense = expense.map { $0.allExpense }
                self?.allExpense = 0
                for member in allExpense {
                    self?.allExpense += abs(member)
                }
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "資料讀取發生錯誤，請稍後再試")
            }
        }
    }
    
    func detectParticipantUser() {
        if groupData?.type == 0 && currentUserId != groupData?.creator {
            groupDetailView.addExpenseButton.isEnabled = false
            groupDetailView.addExpenseButton.isHidden = true
        }
    }
    
    func detectSubscription() {
//        let nowTime = Date().timeIntervalSince1970
        if groupData?.type == 0 {
            SubscriptionManager.shared.fetchSubscriptionData(groupId: groupData?.groupId ?? "") { [weak self] result  in
                switch result {
                case .success(let subscription):
                    self?.subsriptions = subscription
                    if subscription.count > 0 {
                        for indexOfSubscription in 0..<subscription.count {
                            self?.getSubscription(index: indexOfSubscription)
                        }
                    }
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                }
            }
        }
    }
    
    func getSubscription(index: Int) {
        let nowTime = Date().timeIntervalSince1970
        if (subsriptions.count != 0) && subsriptions[index].startTime <= nowTime {
            countSubscriptiontime(index: index)
            subscriptionCreatedTime = subsriptions[index].startTime
            SubscriptionManager.shared.updateSubscriptionData(documentId: subsriptions[index].doucmentId,
                                                              newStartTime: subsriptions[index].startTime)
            SubscriptionManager.shared.fetchSubscriptionInvolvedData(documentId: subsriptions[index].doucmentId) {
                [weak self] result in
                switch result {
                case .success(let subscriptionMember):
                    self?.subscriptInvolvedItem = subscriptionMember
                    self?.addSubscriptionItem(index: index)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                }
            }
        }
    }
    
    func countSubscriptiontime(index: Int) {
        let startTime = subsriptions[index].startTime
        let endTime = subsriptions[index].endTime
        let startTimeInterval = TimeInterval(startTime)
        let endTimeInterval = TimeInterval(endTime)
        var startDate = Date(timeIntervalSince1970: startTimeInterval)
        let endDate = Date(timeIntervalSince1970: endTimeInterval)
        
        switch subsriptions[index].cycle {
        case 0 :
            let components = Calendar.current.dateComponents([.month], from: startDate, to: endDate)
            let month = components.month
            if month ?? 0 > 1 {
                var dateComponent = DateComponents()
                dateComponent.month = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
                subsriptions[index].startTime = startDate.timeIntervalSince1970
            } else {
                SubscriptionManager.shared.deleteSubscriptionDocument(documentId: subsriptions[index].doucmentId)
            }
        case 1 :
            let components = Calendar.current.dateComponents([.year], from: startDate, to: endDate)
            let year = components.year
            if year ?? 0 > 1 {
                var dateComponent = DateComponents()
                dateComponent.year = 1
                startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
                subsriptions[index].startTime = startDate.timeIntervalSince1970
            } else {
                SubscriptionManager.shared.deleteSubscriptionDocument(documentId: subsriptions[index].doucmentId)
            }
        default:
            return
        }
    }
    
    func addSubscriptionItem(index: Int) {
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "",
                                       itemName: subsriptions[index].itemName,
                                       itemDescription: "",
                                       createdTime: self.subscriptionCreatedTime ?? 0,
                                       itemImage: nil) { itemId in
            var paidUserId: String?
            paidUserId = self.subsriptions[index].paidUser
            
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId ?? "",
                                           price: self.subsriptions[index].paidPrice,
                                           itemId: itemId,
                                           createdTime: self.subscriptionCreatedTime ?? 0) {
                result in
                switch result{
                case .success:
                    print("success")
                case .failure(let error):
                    print(error)
                }
            }
            
            for user in 0..<self.subscriptInvolvedItem.count {
                ItemManager.shared.addInvolvedInfo(involvedUserId: self.subscriptInvolvedItem[user].involvedUser,
                                                   price: self.subscriptInvolvedItem[user].involvedPrice,
                                                   itemId: itemId,
                                                   createdTime: self.subscriptionCreatedTime ?? 0) {
                    result in
                    switch result{
                    case .success:
                        print("success")
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            self.countPersonalExpense(index: index)
        }
    }
    
    func countPersonalExpense(index: Int) {
        var paidUserId: String?
        paidUserId = subsriptions[index].paidUser
        GroupManager.shared.updateMemberExpense(userId: paidUserId ?? "",
                                                newExpense: self.subsriptions[index].paidPrice,
                                                groupId: groupData?.groupId ?? "") {
            result in
            switch result{
            case .success:
                print("success")
            case .failure(let error):
                print(error)
            }
        }
        
        for user in 0..<self.subscriptInvolvedItem.count {
            GroupManager.shared.updateMemberExpense(userId: self.subscriptInvolvedItem[user].involvedUser,
                                                    newExpense: 0 - self.subscriptInvolvedItem[user].involvedPrice,
                                                    groupId: groupData?.groupId ?? "") {
                result in
                switch result{
                case .success:
                    print("success")
                case .failure(let error):
                    print(error)
                }
            }
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
    
    func addItemAlert() {
        let alertController = UIAlertController(title: "不可新增", message: "已封存群組無法新增款項", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setAnimation() {
        mask.frame = CGRect(x: 0, y: 0, width: width, height: height)
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.addSubview(mask)

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
        mask.removeFromSuperview()
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
            let paidPrice = paid?.price ?? 0
            let revealExpense = String(format: "%.2f", paidPrice)
            
            if item.itemName == "結帳" {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.settleUpInvolved,
                                         price: paid?.price ?? 0)
                itemsCell.paidDescription.textColor = UIColor.styleRed
                itemsCell.setIcon(style: 0)
            } else {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.paid,
                                         price: paid?.price ?? 0)
                itemsCell.paidDescription.textColor = UIColor.styleGreen
                itemsCell.setIcon(style: 0)
            }
        } else {
            let involvedPrice = involved?.price ?? 0
            let revealExpense = String(format: "%.2f", involvedPrice)
            if involved?.userId == currentUserId {
                if item.itemName == "結帳" {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName,
                                             description: PaidDescription.settleUpPaid,
                                             price: involved?.price ?? 0)
                    itemsCell.paidDescription.textColor = UIColor.styleGreen
                    itemsCell.setIcon(style: 1)
                } else {
                    itemsCell.createItemCell(time: time,
                                             name: item.itemName,
                                             description: PaidDescription.involved,
                                             price: involved?.price ?? 0)
                    itemsCell.paidDescription.textColor = UIColor.styleRed
                    itemsCell.setIcon(style: 1)
                }
            } else {
                itemsCell.createItemCell(time: time,
                                         name: item.itemName,
                                         description: PaidDescription.notInvolved,
                                         price: 0)
                itemsCell.paidDescription.textColor = UIColor.greenWhite
                itemsCell.setIcon(style: 2)
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
        itemDetailViewController.blackList = blackList
        itemDetailViewController.personalExpense = expense
        
        self.show(itemDetailViewController, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    private func animateTableView() {
        let cells = itemTableView.visibleCells
        let tableHeight: CGFloat = itemTableView.bounds.size.height
        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            UIView.animate(withDuration: 0.8,
                           delay: 0.05 * Double(index),
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
        }
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
                detailViewController.blackList = self.blackList
                detailViewController.memberExpense = self.allExpense 

                self.show(detailViewController, sender: nil)
            }
            
            let closeAction = UIAction(title: "封存群組", image: UIImage(systemName: "eye.slash")) { [weak self] action in
                
                if self?.groupData?.status == GroupStatus.inActive.typeInt {
                    self?.disableCloseGroup()
                } else {
                    self?.confirmCloseGroupAlert()
                }
                
            }

            return UIMenu(title: "", children: [infoAction, closeAction])
        }
    }
}

extension CustomGroupViewController {
    func setNoDataView() {
        self.view.addSubview(noDataView)
        noDataView.noDataLabel.text = "群組內尚未新增款項"
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 10).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func revealBlockView() {
        mask = UIView(frame: CGRect(x: 0, y: -0, width: width, height: height))
        mask.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        view.addSubview(mask)
        
        reportView = ReportView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: 300))
        reportView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.reportView.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        }, completion: nil)
        view.addSubview(reportView)
        
        reportView.reportButton.addTarget(self, action: #selector(reportAlert), for: .touchUpInside)
        
        reportView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    @objc func reportAlert() {
        let alertController = UIAlertController(title: "檢舉", message: "請輸入檢舉內容", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "檢舉原因"
        }
        let reportAlert = UIAlertAction(title: "檢舉", style: .default) { [weak self] _ in
            self?.reportContent = alertController.textFields?[0].text
//            self?.leaveGroupAlert()
            self?.report()
        }
        let cancelAlert = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAlert)
        alertController.addAction(reportAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    func report() {
        let report = Report(groupId: groupData?.groupId ?? "",
                            itemId: item?.itemId ?? "",
                            reportContent: reportContent)
        ReportManager.shared.updateReport(report: report) { [weak self] result in
            switch result {
            case .success():
                self?.leaveGroupAlert()
            case .failure(let err):
                print("\(err.localizedDescription)")
            }
        }
    }
    
    func leaveGroupAlert() {
        let alertController = UIAlertController(title: "退出群組", message: "檢舉內容已回報。請確認是否退出群組，退出群組後，將無法查看群組內容。群組建立者離開群組後，群組將封存。", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "退出群組", style: .destructive) { [weak self] _ in
            self?.detectUserExpense()
            self?.pressDismissButton()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func leaveGroup() {
        let groupId = groupData?.groupId
        var isLeaveGroup: Bool = false
        
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        
        firstQueue.async(group: group) {
            GroupManager.shared.removeGroupMember(groupId: groupId ?? "",
                                                  userId: self.currentUserId) { result in
                switch result {
                case .success:
                    print("leave group")
                    isLeaveGroup = true
                case .failure:
                    print("remove group member failed")
                    isLeaveGroup = false
                }
                group.leave()
            }
            
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        secondQueue.async(group: group) {
            GroupManager.shared.removeGroupExpense(groupId: groupId ?? "",
                                                   userId: self.currentUserId) { result in
                switch result {
                case .success:
                    print("leave group")
                    isLeaveGroup = true
                case .failure:
                    print("remove member expense failed")
                    isLeaveGroup = false
                }
                group.leave()
            }
           
        }
        
        let thirdQueue = DispatchQueue(label: "thirdQueue", qos: .default, attributes: .concurrent)
        group.enter()
        thirdQueue.async(group: group) {
            GroupManager.shared.addLeaveMember(groupId: groupId ?? "",
                                               userId: self.currentUserId) { result in
                switch result {
                case .success:
                    print("leave group")
                    isLeaveGroup = true
                case .failure:
                    print("remove member expense failed")
                    isLeaveGroup = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if isLeaveGroup == true {
                ProgressHUD.shared.view = self.view
                ProgressHUD.showSuccess(text: "成功退出群組")
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                ProgressHUD.shared.view = self.view
                ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
            }
        }
    }
    
    func detectUserExpense() {
        if expense == 0 {
            leaveGroup()
        } else {
            rejectLeaveGroupAlert()
        }
    }
    
    func rejectLeaveGroupAlert() {
        let alertController = UIAlertController(title: "無法退出群組",
                                                message: "您在群組內還有債務關係，無法退出。請先結清帳務。",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func pressDismissButton() {
        let subviewCount = self.view.subviews.count
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.subviews[subviewCount - 1].frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        }, completion: nil)
        mask.removeFromSuperview()
    }
}
