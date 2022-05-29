//
//  ItemDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemDetailViewController: BaseViewController {
    
    // MARK: - Property
    var reportView = ReportView()
    var reportViewBottom: NSLayoutConstraint?
    let photoView = UIView()
    var tableView = UITableView()
    
    let currentUserId = UserManager.shared.currentUser?.userId ?? ""
    var itemId: String?
    var item: ItemData?
    var group: GroupData?
    var userData: [UserData] = []
    var personalExpense: Double?
    var reportContent: String?
    var image: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        addMenu()
        setTableView()
        detectBlockListUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAnimation()
        getItemData(itemId: self.itemId ?? "")
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        removeAnimation()
    }
    
    // MARK: - Method
    func getItemData(itemId: String) {
        ItemManager.shared.fetchItem(itemId: itemId) { [weak self] result in
            switch result {
            case .success(let items):
                self?.item = items
                self?.getItemExpense()
            case .failure:
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func getItemExpense() {
        let group = DispatchGroup()
        var isGetItemExpenseSuccess: Bool = false
        group.enter()
        DispatchQueue.global().async {
            ItemManager.shared.fetchPaidItemExpense(itemId: self.item?.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.paidInfo = items
                    isGetItemExpenseSuccess = true
                case .failure:
                    isGetItemExpenseSuccess = false
                }
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.global().async {
            ItemManager.shared.fetchInvolvedItemExpense(itemId: self.item?.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.involedInfo = items
                    isGetItemExpenseSuccess = true
                case .failure:
                    isGetItemExpenseSuccess = false
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            if isGetItemExpenseSuccess {
                self?.tableView.reloadData()
                self?.removeAnimation()
            } else {
                self?.showFailure(text: ErrorType.generalError.errorMessage)
            }
        }
    }
    
    func getPayUser() -> [UserData] {
        var paidUser = userData.filter { $0.userId == item?.paidInfo?[0].userId }
        guard let leaveMemberData = group?.leaveMemberData else { return [] }
        if leaveMemberData.isEmpty == false && paidUser.count == 0 {
            paidUser = leaveMemberData.filter { $0.userId == item?.paidInfo?[0].userId }
            paidUser[0].userName = paidUser[0].userName + "(已離開群組)"
        }
        return paidUser
    }
    
    func getInvolvedUser() -> [UserData] {
        guard let involvedExpense = item?.involedInfo else { return [] }
        var involvedUser: [UserData] = []
        for index in 0..<involvedExpense.count {
            involvedUser += userData.filter { $0.userId == involvedExpense[index].userId }
        }
        
        guard let leaveMemberData = group?.leaveMemberData else { return [] }
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
            return involvedUser
        } else {
            return involvedUser
        }
    }
    
    func deleteItem() {
        guard let group = group,
              let item = item
        else { return }
        
        DeleteItemManager.shared.deleteItem(groupId: group.groupId,
                                            itemId: itemId ?? "",
                                            item: item) { [weak self] in
            
            if DeleteItemManager.shared.isItemDeleteSucces == true {
                ItemManager.shared.addNotify(grpupId: group.groupId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.showSuccess(text: SuccessType.deleteSuccess.successMessage)
                    case .failure:
                        self?.showFailure(text: ErrorType.dataDeleteError.errorMessage)
                    }
                }
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showFailure(text: ErrorType.dataDeleteError.errorMessage)
            }
        }
    }
    
    func detectBlockListUser() {
        let blockList = UserManager.shared.currentUser?.blackList
        guard let blockList = blockList else { return }
        let newUserData = UserManager.renameBlockedUser(blockList: blockList,
                                                        userData: userData)
        userData = newUserData
    }
    
    func alertDeleteItem() {
        let alertController = UIAlertController(title: "刪除款項",
                                                message: "刪除後無法復原，請確認是否刪除款項",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.setAnimation()
            self?.deleteItem()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func revealBlockView() {
        mask.backgroundColor = .maskBackgroundColor
        view.stickSubView(mask)
        
        setReviewView()
        reportView.backgroundColor = .viewDarkBackgroundColor
        reportViewBottom?.constant = -300
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        
        reportView.reportButton.addTarget(self, action: #selector(reportAlert), for: .touchUpInside)
        reportView.dismissButton.addTarget(self, action: #selector(pressDismissButton), for: .touchUpInside)
    }
    
    private func setReviewView() {
        reportView.removeFromSuperview()
        view.addSubview(reportView)
        reportView.translatesAutoresizingMaskIntoConstraints = false
        reportView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        reportView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        reportView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        reportViewBottom = reportView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        reportViewBottom?.isActive = true
        reportView.backgroundColor = .viewDarkBackgroundColor
        
        view.layoutIfNeeded()
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
                            itemId: itemId ?? "",
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
        let alertController = UIAlertController(title: "退出群組",
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
        LeaveGroupManager.shared.leaveGroup(groupId: groupId, currentUserId: currentUserId) { [weak self] in
            if LeaveGroupManager.shared.isLeaveGroupSuccess == true {
                self?.showSuccess(text: "成功退出群組")
            } else {
                self?.showSuccess(text: ErrorType.generalError.errorMessage)
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
        let alertController = UIAlertController(title: "無法退出群組",
                                                message: "您在群組內還有債務關係，無法退出。請先結清帳務。",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func pressDismissButton() {
        reportViewBottom?.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: UIView.AnimationOptions.curveEaseIn, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
        mask.removeFromSuperview()
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }
        
        let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
        guard let itemImageViewController = storyBoard.instantiateViewController(
            withIdentifier: String(describing: ItemImageViewController.self)
        ) as? ItemImageViewController else { return }
        itemImageViewController.image = image
        itemImageViewController.modalPresentationStyle = .fullScreen
        self.present(itemImageViewController, animated: true, completion: nil)
        
    }
    
    @objc func dismissPhotoView() {
        photoView.removeFromSuperview()
    }
}

extension ItemDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let item = item else { return 0 }
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
        guard let item = item else {
            return UITableViewCell()
            
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ItemDetailTableViewCell.self),
                for: indexPath
            )
            guard let detailCell = cell as? ItemDetailTableViewCell else {
                return cell
                
            }
            let paidUser = getPayUser()
            if !paidUser.isEmpty {
                detailCell.createDetailCell(group: group?.groupName ?? "",
                                            item: item,
                                            paidMember: paidUser[0].userName)
            }
            
            if item.itemImage != nil {
                self.image = item.itemImage
                let tapGestureRecognizer = UITapGestureRecognizer(
                    target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
                detailCell.itemImage.isUserInteractionEnabled = true
                detailCell.itemImage.addGestureRecognizer(tapGestureRecognizer)
            }
            
            return detailCell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ItemMemberTableViewCell.self),
                for: indexPath
            )
            guard let memberCell = cell as? ItemMemberTableViewCell else { return cell }
            let involvedUser = getInvolvedUser()
            if !involvedUser.isEmpty {
                memberCell.createItemMamberCell(involedMember: involvedUser[indexPath.row].userName,
                                                involvedPrice: item.involedInfo?[indexPath.row].price ?? 0)
            }
            return memberCell
        }
    }
}

extension ItemDetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(
                identifier: nil, previewProvider: nil
            ) { _ in
                
                let editAction = UIAction(title: "編輯",
                                          image: UIImage(systemName: "pencil")) { _ in
                    let storyBoard = UIStoryboard(name: StoryboardCategory.groups, bundle: nil)
                    guard let addItemViewController = storyBoard.instantiateViewController(
                        withIdentifier: String(describing: AddItemViewController.self)
                    ) as? AddItemViewController else { return }
                    addItemViewController.group = self.group
                    addItemViewController.itemData = self.item
                    addItemViewController.isItemExist = true
                    addItemViewController.editingItem = { [weak self] newItemId in
                        self?.getItemData(itemId: newItemId)
                    }
                    self.present(addItemViewController, animated: true, completion: nil)
                }
                
                let removeAction = UIAction(title: "刪除",
                                            image: UIImage(systemName: "trash")) { _ in
                    self.alertDeleteItem()
                }
                
                let reportAction = UIAction(title: "檢舉",
                                            image: UIImage(systemName: "megaphone")) { _ in
                    self.revealBlockView()
                }
                return UIMenu(title: "", children: [editAction, removeAction, reportAction])
            }
        }
}

extension ItemDetailViewController {
    func addMenu() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        if group?.status == GroupStatus.active.typeInt {
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
        tableView.register(UINib(nibName: String(describing: ItemDetailTableViewCell.self),
                                 bundle: nil), forCellReuseIdentifier: String(describing: ItemDetailTableViewCell.self))
        tableView.register(UINib(nibName: String(describing: ItemMemberTableViewCell.self),
                                 bundle: nil), forCellReuseIdentifier: String(describing: ItemMemberTableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }
    
    func setTableViewConstraint() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
    }
    
    func addImageView(image: String) {
        view.addSubview(photoView)
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        photoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        photoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        photoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        photoView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        
        let photoImage = UIImageView()
        photoView.addSubview(photoImage)
        photoImage.getImage(image)
        photoImage.contentMode = .scaleAspectFit
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        photoImage.centerXAnchor.constraint(equalTo: photoView.centerXAnchor).isActive = true
        photoImage.centerYAnchor.constraint(equalTo: photoView.centerYAnchor).isActive = true
        photoImage.widthAnchor.constraint(equalToConstant: UIScreen.width).isActive = true
        photoImage.heightAnchor.constraint(equalToConstant: UIScreen.height - 200).isActive = true
        
        let dismissButton = UIButton()
        photoView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: photoView.topAnchor, constant: 10).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: photoView.rightAnchor, constant: -10).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .greenWhite
        
        dismissButton.addTarget(self, action: #selector(dismissPhotoView), for: .touchUpInside)
    }
}
