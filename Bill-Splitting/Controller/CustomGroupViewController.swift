//
//  MultipleUsersGrouplViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class CustomGroupViewController: BaseViewController {
    
// MARK: - Property
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    let groupDetailView = GroupDetailView(frame: .zero)
    let itemTableView = UITableView()
    let subscribeButton = UIButton()
    var noDataView = NoDataView(frame: .zero)
    
    var group: GroupData?
    var members: [UserData] = []
    var items: [ItemData] = []
    
    var reportView = ReportView()
    var reportContent: String?
    var reportItem: ItemData?
    
    var personalExpense: Double? {
        didSet {
            if personalExpense ?? 0 >= 0 {
                let revealExpense = String(format: "%.2f", personalExpense ?? 0)
                groupDetailView.personalFinalPaidLabel.text = "你的總支出為：\(revealExpense) 元"
            } else {
                let revealExpense = String(format: "%.2f", abs(personalExpense ?? 0))
                groupDetailView.personalFinalPaidLabel.text = "你的總欠款為：\(revealExpense) 元"
            }
        }
    }
    
    var subsriptions: [Subscription] = []
    var subscriptionCreatedTime: Double?
    var blockList: [String] = []
    
// MARK: - Lifecycle
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
        navigationItem.title = NavigationItemName.group.name
        getMemberExpense()
        listenToNewItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        getUserData()
        getItemData()
        getLeaveMemberData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
// MARK: - Method
    func setGroupDetailView() {
        view.addSubview(groupDetailView)
        setGroupDetailViewConstraint()
        
        groupDetailView.groupName.text = group?.groupName ?? ""
        groupDetailView.addExpenseButton.addTarget(self, action: #selector(pressAddItem), for: .touchUpInside)
        groupDetailView.chartButton.addTarget(self, action: #selector(pressChartButton), for: .touchUpInside)
        groupDetailView.settleUpButton.addTarget(self, action: #selector(pressSettleUp), for: .touchUpInside)
        
        groupDetailView.personalFinalPaidLabel.text = "你的總支出為："
        hideAddItemButton()
    }
    
    func setItemTableView() {
        self.view.addSubview(itemTableView)
        setTableViewConstraint()
        
        itemTableView.register(
            UINib(nibName: String(describing: ItemTableViewCell.self), bundle: nil),
            forCellReuseIdentifier: String(describing: ItemTableViewCell.self))
        itemTableView.dataSource = self
        itemTableView.delegate = self
        
        itemTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        itemTableView.backgroundColor = UIColor.clear
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        itemTableView.addGestureRecognizer(longPress)
    }
    
    func setSubscribeButton() {
        view.addSubview(subscribeButton)
        setSubscribeButtonConstraint()
        subscribeButton.setImage(UIImage(systemName: "calendar"), for: .normal)
        subscribeButton.setTitle("設定週期", for: .normal)
        subscribeButton.addTarget(self, action: #selector(pressSubscribe), for: .touchUpInside)
        ElementsStyle.styleSpecificButton(subscribeButton)
        hideSubscribeButton()
    }

    func getUserData() {
        members.removeAll()
        group?.memberData?.removeAll()
        UserManager.shared.fetchMembersData(membersId: group?.member ?? []) { [weak self] result in
            switch result {
            case .success(let users):
                self?.members = users
                self?.group?.memberData = users
            case .failure:
                self?.showFailure(text: ErrorType.dataError.errorMessage)
            }
        }
    }
    
    func listenToNewItem() {
        ItemManager.shared.listenForNotification(groupId: group?.groupId ?? "") { [weak self] in
            self?.getItemData()
        }
    }
    
    func getItemData() {
        ItemManager.shared.fetchGroupItemData(groupId: group?.groupId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                self?.hideNoDataLabel(items)
                self?.items = items
                self?.getItemDetail()
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func getItemDetail() {
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        
        for (index, item) in self.items.enumerated() {
            group.enter()
            
            firstQueue.async(group: group) {
                ItemManager.shared.fetchPaidItemExpense(itemId: item.itemId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.items[index].paidInfo = items
                    case .failure:
                        self?.showFailure(text: ErrorType.generalError.errorMessage)
                    }
                    group.leave()
                }
            }
        }
       
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        
        for (index, item) in self.items.enumerated() {
            group.enter()
            secondQueue.async(group: group) {
                ItemManager.shared.fetchInvolvedItemExpense(itemId: item.itemId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.items[index].involedInfo = items
                    case .failure:
                        self?.showFailure(text: ErrorType.generalError.errorMessage)
                    }
                    group.leave()
                }
            }
        }
 
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.itemTableView.reloadData()
            self?.removeAnimation()
        }
    }
    
    func getMemberExpense() {
        group?.memberExpense = []
        guard let group = group else { return }
        GroupManager.shared.fetchMemberExpense(
            groupId: group.groupId ,
            members: group.member
        ) { [weak self] result in
            switch result {
            case .success(let expense):
                self?.group?.memberExpense = expense
                self?.getPesronalExpense(expense)
            case .failure:
                self?.showFailure(text: ErrorType.dataError.errorMessage)
            }
        }
    }
    
    fileprivate func getPesronalExpense(_ expense: ([MemberExpense])) {
        let userExpense = expense.filter { $0.userId == (self.currentUserId) }
        if userExpense.isEmpty == false {
            self.personalExpense = userExpense[0].allExpense
        }
    }
    
    func getLeaveMemberData() {
        group?.leaveMemberData = []
        if group?.leaveMembers != nil {
            UserManager.shared.fetchMembersData(membersId: group?.leaveMembers ?? []) {  [weak self] result in
                switch result {
                case .success(let userData):
                    self?.group?.leaveMemberData = userData
                case .failure:
                    self?.showFailure(text: ErrorType.generalError.errorMessage)
                }
            }
        }
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: itemTableView)
            if let indexPath = itemTableView.indexPathForRow(at: touchPoint) {
                reportItem = items[indexPath.row]
                showBlockView()
            }
        }
    }
    
    func pressClosedGroup() {
        GroupManager.shared.updateGroupStatus(groupId: group?.groupId ?? "") { [weak self] result in
            switch result {
            case .success:
                self?.showSuccess(text: "成功封存群組")
            case .failure:
                self?.showFailure(text: "封存群組失敗，請稍後再試")
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func confirmCloseGroupAlert() {
        let alertController = UIAlertController(title: "請確認是否封存群組", message: "封存後群組內容將不可編輯", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "封存", style: .destructive) { [weak self] _ in
            self?.pressClosedGroup()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func disableCloseGroupButton() {
        confirmAlert(title: "群組已封存", message: "不可重複封存群組")
    }
    
    func detectSubscription() {
        if group?.type == GroupType.personal.typeInt {
            SubscriptionManager.shared.fetchSubscriptionData(groupId: group?.groupId ?? "") { [weak self] result  in
                switch result {
                case .success(let subscription):
                    self?.subsriptions = subscription
                    if subscription.count > 0 {
                        for indexOfSubscription in 0..<subscription.count {
                            self?.getSubscription(index: indexOfSubscription)
                        }
                    } else {
                        return
                    }
                case .failure:
                    self?.showFailure(text: ErrorType.generalError.errorMessage)
                }
            }
        } else {
            return
        }
    }
    
    fileprivate func updateSubscription(_ index: Int) {
        SubscriptionManager.shared.updateSubscriptionData(
            documentId: subsriptions[index].doucmentId,
            newStartTime: subscriptionCreatedTime ?? 0)
    }
    
    fileprivate func getSubscriptionInvolvedData(_ index: Int) {
        SubscriptionManager.shared.fetchSubscriptionInvolvedData(
            documentId: subsriptions[index].doucmentId) { [weak self] result in
                switch result {
                case .success(let subscriptionMember):
                    self?.subsriptions[index].subscriptionMember = subscriptionMember
                    self?.addSubscriptionItem(index: index)
                case .failure:
                    self?.showFailure(text: ErrorType.generalError.errorMessage)
                }
            }
    }
    
    func getSubscription(index: Int) {
        let nowTime = Date().timeIntervalSince1970
        if (subsriptions.count != 0) && subsriptions[index].startTime <= nowTime {
            countSubscriptiontime(index: index)
            updateSubscription(index)
            getSubscriptionInvolvedData(index)
        }
    }
    
    fileprivate func deleteSubscription(_ index: Int) {
        SubscriptionManager.shared.deleteSubscriptionDocument(documentId: subsriptions[index].doucmentId)
    }
    
    fileprivate func updateSubscriptionMonth(_ startDate: inout Date, _ endDate: Date, _ index: Int) {
        let components = Calendar.current.dateComponents([.month], from: startDate, to: endDate)
        let month = components.month
        if month ?? 0 > 0 {
            var dateComponent = DateComponents()
            dateComponent.month = 1
            startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
            subscriptionCreatedTime = startDate.timeIntervalSince1970
        } else {
            deleteSubscription(index)
        }
    }
    
    fileprivate func updateSubscriptionYear(_ startDate: inout Date, _ endDate: Date, _ index: Int) {
        let components = Calendar.current.dateComponents([.year], from: startDate, to: endDate)
        let year = components.year
        if year ?? 0 > 0 {
            var dateComponent = DateComponents()
            dateComponent.year = 1
            startDate = Calendar.current.date(byAdding: dateComponent, to: startDate) ?? Date()
            subscriptionCreatedTime = startDate.timeIntervalSince1970
        } else {
            deleteSubscription(index)
        }
    }
    
    func getTimeDate(timeStamp: Double) -> Date {
        let timeStamp = timeStamp
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        return date
    }
    
    func countSubscriptiontime(index: Int) {
        var startDate = getTimeDate(timeStamp: subsriptions[index].startTime)
        let endDate = getTimeDate(timeStamp: subsriptions[index].endTime)
        
        switch subsriptions[index].cycle {
        case Cycle.month.typeInt :
            updateSubscriptionMonth(&startDate, endDate, index)
        case Cycle.year.typeInt :
            updateSubscriptionYear(&startDate, endDate, index)
        default:
            return
        }
    }
    
    func addSubscriptionItem(index: Int) {
        ItemManager.shared.addItemData(groupId: group?.groupId ?? "",
                                       itemName: subsriptions[index].itemName,
                                       itemDescription: "",
                                       createdTime: subsriptions[index].startTime,
                                       itemImage: nil) { [weak self] itemId in
            var paidUserId: String?
            paidUserId = self?.subsriptions[index].paidUser
            
            let subscriptInvolved: [ExpenseInfo]  = self?.getSubscriptionInvolved(index: index) ?? []
            let subscriptInvolvedPrice: [Double] = self?.getSubscriptionPrice(index: index) ?? []
            
            AddItem.shared.addItem(
                groupId: self?.group?.groupId ?? "",
                itemId: itemId,
                paidUserId: paidUserId ?? "",
                paidPrice: self?.subsriptions[index].paidPrice ?? 0,
                involvedExpenseData: subscriptInvolved,
                involvedPrice: subscriptInvolvedPrice) { [weak self] in
                    self?.getItemData()
                }
        }
    }
    
    func getSubscriptionInvolved(index: Int) -> [ExpenseInfo] {
        let subscriptInvolvedItem = subsriptions[index].subscriptionMember
        var subscriptInvolved: [ExpenseInfo] = []
        for user in 0..<(subscriptInvolvedItem?.count ?? 0) {
            let involvedExpense = ExpenseInfo(
                userId: subscriptInvolvedItem?[user].involvedUser ?? "",
                price: subscriptInvolvedItem?[user].involvedPrice ?? 0,
                createdTime: nil, itemId: nil)
            subscriptInvolved.append(involvedExpense)
        }
        return subscriptInvolved
    }
    
    func getSubscriptionPrice(index: Int) -> [Double] {
        let subscriptInvolvedItem = subsriptions[index].subscriptionMember
        var  subscriptInvolvedPrice: [Double] = []
        for user in 0..<(subscriptInvolvedItem?.count ?? 0) {
            subscriptInvolvedPrice.append(subscriptInvolvedItem?[user].involvedPrice ?? 0)
        }
        return subscriptInvolvedPrice
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
        confirmAlert(title: "不可新增", message: "已封存群組無法新增款項")
    }
    
    @objc func pressAddItem() {
        if group?.status == GroupStatus.active.typeInt {
            let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
            guard let addItemViewController = storyBoard.instantiateViewController(
                withIdentifier: String(describing: AddItemViewController.self)
            ) as? AddItemViewController else { return }
            addItemViewController.group = group
            addItemViewController.blockList = blockList
            addItemViewController.modalPresentationStyle = .fullScreen
            self.present(addItemViewController, animated: true, completion: nil)
        } else {
            addItemAlert()
        }
    }
    
    @objc func pressChartButton() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let chartViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: ChartViewController.self)
        ) as? ChartViewController else { return }
        chartViewController.group = group
        chartViewController.blockList = blockList
        chartViewController.modalPresentationStyle = .fullScreen
        self.present(chartViewController, animated: true, completion: nil)
    }
    
    @objc func pressSettleUp() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let settleUpViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: SettleUpViewController.self)
        ) as? SettleUpViewController else { return }
        
        settleUpViewController.group = group
        settleUpViewController.expense = personalExpense
        settleUpViewController.blockList = blockList

        self.show(settleUpViewController, sender: nil)
    }
    
    @objc func pressSubscribe() {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let subscribeViewController =
                storyBoard.instantiateViewController(
                    withIdentifier: String(describing: SubscribeViewController.self)
                ) as? SubscribeViewController else { return }
        subscribeViewController.memberId = group?.member
        subscribeViewController.memberData = members
        subscribeViewController.groupData = group
        subscribeViewController.blackList = blockList
        self.present(subscribeViewController, animated: true, completion: nil)
    }
    
    func getTimeString(timeStamp: Double) -> String {
        let timeStamp = timeStamp
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let time = dateFormatter.string(from: date)
        return time
    }
    
    func getPaidInfo(item: ItemData) -> ExpenseInfo? {
        var paid: ExpenseInfo?
        for index in 0..<items.count {
            if items[index].paidInfo?[0].itemId == item.itemId {
                paid = items[index].paidInfo?[0]
            }
        }
        return paid
    }
    
    func getInvolvedInfo(item: ItemData) -> ExpenseInfo? {
        var involves = [ExpenseInfo]()
        var involved: ExpenseInfo?
        for index in 0..<items.count {
            involves = items[index].involedInfo ?? []
            for  involve in 0..<involves.count {
                if involves[involve].itemId == item.itemId && involves[involve].userId == currentUserId {
                    involved = involves[involve]
                }
            }
        }
        return involved
    }
    
}

extension CustomGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: ItemTableViewCell.self),
            for: indexPath
        )
        
        guard let itemsCell = cell as? ItemTableViewCell else { return cell }
        
        let item = items[indexPath.row]
        let paid = getPaidInfo(item: item)
        let involved = getInvolvedInfo(item: item)
        let time = getTimeString(timeStamp: item.createdTime)
        
        if paid?.userId == currentUserId {
            itemsCell.mapItemCell(
                item: item, time: time,
                paidPrice: paid?.price ?? 0,
                involvedPrice: involved?.price ?? 0,
                involvedType: .paid)
        } else if involved?.userId == currentUserId {
            itemsCell.mapItemCell(
                item: item, time: time,
                paidPrice: paid?.price ?? 0,
                involvedPrice: involved?.price ?? 0,
                involvedType: .involved)
        } else {
            itemsCell.mapItemCell(
                item: item, time: time,
                paidPrice: paid?.price ?? 0,
                involvedPrice: involved?.price ?? 0,
                involvedType: .notInvolved)
        }
        return itemsCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let itemDetailViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: ItemDetailViewController.self)
        ) as? ItemDetailViewController else { return }
        
        let item = items[indexPath.row]
        itemDetailViewController.itemId = item.itemId
        itemDetailViewController.userData = members
        itemDetailViewController.groupData = group
        itemDetailViewController.leaveMemberData = group?.leaveMemberData ?? []
        itemDetailViewController.blackList = blockList
        itemDetailViewController.personalExpense = personalExpense
        
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
}

extension CustomGroupViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
           
            let infoAction = UIAction(title: "查看群組資訊", image: UIImage(systemName: "eye")) { [weak self] _ in
                let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
                guard let detailViewController = storyBoard.instantiateViewController(
                    withIdentifier: String(describing: GroupDetailViewController.self)
                ) as? GroupDetailViewController else { return }
                detailViewController.groupData = self?.group
                detailViewController.userData = self?.members ?? []
                detailViewController.personalExpense = self?.personalExpense
                detailViewController.blackList = self?.blockList ?? []

                self?.show(detailViewController, sender: nil)
            }
            
            let closeAction = UIAction(title: "封存群組", image: UIImage(systemName: "eye.slash")) { [weak self] _ in
                if self?.group?.status == GroupStatus.inActive.typeInt {
                    self?.disableCloseGroupButton()
                } else {
                    self?.confirmCloseGroupAlert()
                }
            }
            return UIMenu(title: "", children: [infoAction, closeAction])
        }
    }
}

extension CustomGroupViewController {
    func hideAddItemButton() {
        if group?.type == GroupType.personal.typeInt && currentUserId != group?.creator {
            groupDetailView.addExpenseButton.isEnabled = false
            groupDetailView.addExpenseButton.isHidden = true
        }
    }
    
    func setNoDataView() {
        self.view.addSubview(noDataView)
        noDataView.noDataLabel.text = "群組內尚未新增款項"
        setNoDataViewConstraint()
    }
    
    func showBlockView() {
        view.addSubview(mask)
        setMaskConstraints()
        mask.backgroundColor = .maskBackground
        view.addSubview(mask)
        
        reportView = ReportView(frame: CGRect(x: 0, y: UIScreen.height, width: UIScreen.width, height: 300))
        reportView.backgroundColor = .viewDarkBackground
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.reportView.frame = CGRect(x: 0, y: UIScreen.height - 300, width: UIScreen.width, height: 300)
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
            self?.report()
        }
        let cancelAlert = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAlert)
        alertController.addAction(reportAlert)
        present(alertController, animated: true, completion: nil)
    }
    
    func report() {
        let report = Report(groupId: group?.groupId ?? "",
                            itemId: reportItem?.itemId ?? "",
                            reportContent: reportContent)
        ReportManager.shared.updateReport(report: report) { [weak self] result in
            switch result {
            case .success:
                self?.leaveGroupAlert()
            case .failure(let err):
                print("\(err.localizedDescription)")
            }
        }
    }
    
    func leaveGroupAlert() {
        let alertController = UIAlertController(
            title: "退出群組",
            message: "檢舉內容已回報。請確認是否退出群組，退出群組後，將無法查看群組內容。群組建立者離開群組後，群組將封存。",
            preferredStyle: .alert)
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
        guard let groupId = group?.groupId else { return }
        LeaveGroup.shared.leaveGroup(groupId: groupId, currentUserId: currentUserId) { [weak self] in
            if LeaveGroup.shared.isLeaveGroupSuccess == true {
                self?.showSuccess(text: "成功退出群組")
                self?.navigationController?.popToRootViewController(animated: true)
            } else {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func detectUserExpense() {
        if personalExpense == 0 {
            leaveGroup()
        } else {
            rejectLeaveGroupAlert()
        }
    }
    
    func rejectLeaveGroupAlert() {
        confirmAlert(title: "無法退出群組", message: "您在群組內還有債務關係，無法退出。請先結清帳務。")
    }
    
    @objc func pressDismissButton() {
        let subviewCount = self.view.subviews.count
        
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.view.subviews[subviewCount - 1].frame = CGRect(
                x: 0,
                y: UIScreen.height,
                width: UIScreen.width,
                height: UIScreen.height)
        }, completion: nil)
        mask.removeFromSuperview()
    }
}

extension CustomGroupViewController {
    fileprivate func hideNoDataLabel(_ items: ([ItemData])) {
        if items.isEmpty == true {
            removeAnimation()
            noDataView.noDataLabel.isHidden = false
        } else {
            noDataView.noDataLabel.isHidden = true
        }
    }
    
    fileprivate func hideSubscribeButton() {
        if group?.type == GroupType.multipleUsers.typeInt {
            subscribeButton.isHidden = true
        } else if group?.type == GroupType.personal.typeInt && group?.creator != currentUserId {
            subscribeButton.isHidden = true
        } else {
            subscribeButton.isHidden = false
        }
    }
    
    fileprivate func setGroupDetailViewConstraint() {
        groupDetailView.translatesAutoresizingMaskIntoConstraints = false
        groupDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        groupDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        groupDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        groupDetailView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    fileprivate func setTableViewConstraint() {
        itemTableView.translatesAutoresizingMaskIntoConstraints = false
        itemTableView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 10).isActive = true
        itemTableView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setSubscribeButtonConstraint() {
        subscribeButton.translatesAutoresizingMaskIntoConstraints = false
        subscribeButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        subscribeButton.widthAnchor.constraint(equalToConstant: UIScreen.width/3 - 10).isActive = true
        subscribeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        subscribeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    }
    
    fileprivate func setNoDataViewConstraint() {
        noDataView.translatesAutoresizingMaskIntoConstraints = false
        noDataView.topAnchor.constraint(equalTo: groupDetailView.bottomAnchor, constant: 10).isActive = true
        noDataView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    fileprivate func setMaskConstraints() {
        mask.translatesAutoresizingMaskIntoConstraints = false
        mask.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mask.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mask.widthAnchor.constraint(equalToConstant: UIScreen.width).isActive = true
        mask.heightAnchor.constraint(equalToConstant: UIScreen.height).isActive = true
    }
}   
