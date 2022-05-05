//
//  ItemDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    let currentUserId = AccountManager.shared.currentUser.currentUserId
    var itemId: String?
    var item: ItemData?
    var groupData: GroupData?
    var userData: [UserData] = []
    var tableView = UITableView()
    var paidUser: [UserData] = []
    var involvedUser: [UserData] = []
    var leaveMemberData: [UserData] = []
    var blackList = [String]()
    var personalExpense: Double?
    var reportContent: String?
    
    var reportView = ReportView()
    var mask = UIView()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        addMenu()
        setTableView()
        detectBlackListUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getItemData()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func addMenu() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        if groupData?.status == GroupStatus.active.typeInt {
            let interaction = UIContextMenuInteraction(delegate: self)
            button.addInteraction(interaction)
        } else {
            disableInfoButton()
        }
    }
    
    func disableInfoButton() {
        let alertController = UIAlertController(title: "無法編輯", message: "已封存群組不可編輯或刪除款項", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setTableView() {
        view.addSubview(tableView)
        setTableViewConstraint()
        tableView.register(UINib(nibName: String(describing: ItemDetailTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemDetailTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ItemMemberTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ItemMemberTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setTableViewConstraint() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
    }
    
    func getItemData() {
        ItemManager.shared.fetchItem(itemId: self.itemId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                self?.item = items
                self?.getItemExpense()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }
    
    func getItemExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        firstQueue.async(group: group) {
            ItemManager.shared.fetchPaidItemsExpense(itemId: self.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.paidInfo = items
                    self?.getPayUser()
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
                group.leave()

            }
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        secondQueue.async(group: group) {
            ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.involedInfo = items
                    self?.getInvolvedUser()
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
    }
    
    func getPayUser() {
        paidUser = userData.filter { $0.userId == item?.paidInfo?[0].userId }
        if leaveMemberData.isEmpty == false && paidUser.count == 0 {
            paidUser = leaveMemberData.filter { $0.userId == item?.paidInfo?[0].userId }
            paidUser[0].userName = paidUser[0].userName + "(已離開群組)"
        }
    }
    
    func getInvolvedUser() {
        guard let involvedExpense = item?.involedInfo else {
            return
        }
        for index in 0..<involvedExpense.count {
            involvedUser += userData.filter { $0.userId == involvedExpense[index].userId }
        }
        
        if leaveMemberData.isEmpty == false {
            var leaveUser = [UserData]()
            for index in 0..<involvedExpense.count {
                leaveUser += leaveMemberData.filter { $0.userId == involvedExpense[index].userId }
            }
            
            for index in 0..<leaveUser.count {
                leaveUser[index].userName = leaveUser[index].userName + "(已離開群組)"
            }
            for index in 0..<userData.count {
                leaveUser = leaveUser.filter { $0.userId != userData[index].userId }
            }
            
            involvedUser += leaveUser
        }
    }
    
    func deleteItem() {
        countPersonalExpense()
        ItemManager.shared.deleteItem(itemId: itemId ?? "")
    }
    
    func countPersonalExpense() {
        guard let paidUserId = item?.paidInfo?[0].userId,
              let paidPrice = item?.paidInfo?[0].price
        else { return }
        
        GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                newExpense: 0 - paidPrice,
                                                groupId: groupData?.groupId ?? "")
        
        guard let involvedExpense = item?.involedInfo else { return }
        
        for user in 0..<involvedExpense.count {
            GroupManager.shared.updateMemberExpense(userId: involvedExpense[user].userId,
                                                    newExpense: involvedExpense[user].price,
                                                    groupId: groupData?.groupId ?? "")
        }
    }
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                      userData: userData)
        userData = newUserData
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
                            itemId: itemId ?? "",
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
            self?.navigationController?.popToRootViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func leaveGroup() {
        let groupId = groupData?.groupId
        GroupManager.shared.removeGroupMember(groupId: groupId ?? "",
                                              userId: currentUserId) { result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove group member failed")
            }
        }
        
        GroupManager.shared.removeGroupExpense(groupId: groupId ?? "",
                                               userId: currentUserId) { result in
            switch result {
            case .success:
                print("leave group")
            case .failure:
                print("remove member expense failed")
            }
        }
        
        GroupManager.shared.addLeaveMember(groupId: groupId ?? "",
                                           userId: currentUserId)
    }
    
    func detectUserExpense() {
        if personalExpense == 0 {
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

extension ItemDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            guard let item = item else { return 0 }
            return item.involedInfo?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = item else { return UITableViewCell() }
        
         if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ItemDetailTableViewCell.self),
                for: indexPath
            )
            guard let detailCell = cell as? ItemDetailTableViewCell else { return cell }
            
             detailCell.createDetailCell(group: groupData?.groupName ?? "",
                                        item: item.itemName,
                                        time: item.createdTime,
                                        paidPrice: item.paidInfo?[0].price ?? 0,
                                        paidMember: paidUser[0].userName,
                                        description: item.itemDescription,
                                        image: item.itemImage)
            
            return detailCell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ItemMemberTableViewCell.self),
                for: indexPath
            )
            guard let memberCell = cell as? ItemMemberTableViewCell else { return cell }
            
            memberCell.createItemMamberCell(involedMember: involvedUser[indexPath.row].userName,
                                            involvedPrice: item.involedInfo?[indexPath.row].price ?? 0)
            return memberCell
        }
    }
}

extension ItemDetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
           
            let editAction = UIAction(title: "編輯", image: UIImage(systemName: "pencil")) { action in
                let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
                guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddItemViewController.self)) as? AddItemViewController else { return }
                addItemViewController.memberId = self.groupData?.member
                addItemViewController.memberData = self.userData
                addItemViewController.groupData = self.groupData
                addItemViewController.itemData = self.item
                addItemViewController.isItemExist = true
                self.present(addItemViewController, animated: true, completion: nil)
            }
           
            let removeAction = UIAction(title: "刪除", image: UIImage(systemName: "trash")) { action in
                self.deleteItem()
                self.navigationController?.popViewController(animated: true)
            }
            
            let reportAction = UIAction(title: "檢舉", image: UIImage(systemName: "megaphone")) { action in
                self.revealBlockView()
            }
            return UIMenu(title: "", children: [editAction, removeAction, reportAction])
        }
    }
}
