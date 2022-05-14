//
//  ItemDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit
import Lottie
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
    private var animationView = AnimationView()
    var mask = UIView()
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    let photoView = UIView()
    var image: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        addMenu()
        setTableView()
        detectBlackListUser()
//        getItemData()
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
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10).isActive = true
    }
    
    func getItemData(itemId: String) {
        ItemManager.shared.fetchItem(itemId: itemId) { [weak self] result in
            switch result {
            case .success(let items):
                self?.item = items
                self?.getItemExpense()
            case .failure(let error):
                print("Error decoding userData: \(error)")
                ProgressHUD.shared.view = self?.view ?? UIView()
                ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
            }
        }
    }
    
    func getItemExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        firstQueue.async(group: group) {
            ItemManager.shared.fetchPaidItemsExpense(itemId: self.item?.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.paidInfo = items
                    self?.getPayUser()
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
            ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.item?.itemId ?? "") { [weak self] result in
                switch result {
                case .success(let items):
                    self?.item?.involedInfo = items
                    self?.getInvolvedUser()
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    ProgressHUD.shared.view = self?.view ?? UIView()
                    ProgressHUD.showFailure(text: "發生錯誤，請稍後再試")
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
            self.removeAnimation()
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
        guard let paidUserId = item?.paidInfo?[0].userId,
              let paidPrice = item?.paidInfo?[0].price
        else { return }
        var isItemDeleteSucces: Bool = false
        
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        firstQueue.async(group: group) {
            GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                    newExpense: 0 - paidPrice,
                                                    groupId: self.groupData?.groupId ?? "") { result in
                switch result {
                case .success:
                    print("success")
                    isItemDeleteSucces = true
                case .failure(let error):
                    print(error.localizedDescription)
                    isItemDeleteSucces = false
                }
                group.leave()
            }
        }
        
        guard let involvedExpense = item?.involedInfo else { return }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        
        for user in 0..<involvedExpense.count {
            group.enter()
            secondQueue.async(group: group) {
                GroupManager.shared.updateMemberExpense(userId: involvedExpense[user].userId,
                                                        newExpense: involvedExpense[user].price,
                                                        groupId: self.groupData?.groupId ?? "") { result in
                    switch result {
                    case .success:
                        print("success")
                        isItemDeleteSucces = true
                        group.leave()
                    case .failure(let error):
                        print(error.localizedDescription)
                        isItemDeleteSucces = false
                        group.leave()
                    }
                }
            }
        }
        
        let thirdQueue = DispatchQueue(label: "thirdQueue", qos: .default, attributes: .concurrent)
        group.enter()
        thirdQueue.async(group: group) {
            ItemManager.shared.deleteItem(itemId: self.itemId ?? "") { result in
                switch result {
                case .success:
                    print("success")
                    isItemDeleteSucces = true
                case .failure(let error):
                    print(error.localizedDescription)
                    isItemDeleteSucces = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if isItemDeleteSucces == true {
                ProgressHUD.shared.view = self.view ?? UIView()
                ProgressHUD.showSuccess(text: "移除成功")
                self.navigationController?.popViewController(animated: true)
            } else {
                ProgressHUD.shared.view = self.view ?? UIView()
                ProgressHUD.showFailure(text: "移除失敗，請稍後再試")
            }
        }
    }
    
    func detectBlackListUser() {
        let newUserData = UserManager.renameBlockedUser(blockList: blackList,
                                      userData: userData)
        userData = newUserData
    }
    
    func alertDeleteItem() {
        let alertController = UIAlertController(title: "刪除款項",
                                                message: "刪除後無法復原，請確認是否刪除款項",
                                                preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { [weak self]_ in
            self?.deleteItem()
//            self?.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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
            case .success:
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
//            self?.navigationController?.popToRootViewController(animated: true)
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
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
       
        guard let tappedImage = tapGestureRecognizer.view as? UIImageView else { return }

//        addImageView(image: self.image ?? "")
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let itemImageViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: ItemImageViewController.self)) as? ItemImageViewController else { return }
        itemImageViewController.image = image
        itemImageViewController.modalPresentationStyle = .fullScreen
        self.present(itemImageViewController, animated: true, completion: nil)
        
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
        photoImage.widthAnchor.constraint(equalToConstant: width).isActive = true
        photoImage.heightAnchor.constraint(equalToConstant: height - 200).isActive = true
        
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
    
    @objc func dismissPhotoView() {
        photoView.removeFromSuperview()
    }
    
    func setAnimation() {
        animationView = .init(name: "accountLoading")
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
            
             detailCell.createDetailCell(group: groupData?.groupName ?? "",
                                        item: item.itemName,
                                        time: item.createdTime,
                                        paidPrice: item.paidInfo?[0].price ?? 0,
                                        paidMember: paidUser[0].userName,
                                        description: item.itemDescription,
                                        image: item.itemImage)
             
             if item.itemImage != nil {
                 self.image = item.itemImage
                 let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
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
                addItemViewController.editingItem = { [weak self] newItemId in
                    self?.getItemData(itemId: newItemId)
                }
                self.present(addItemViewController, animated: true, completion: nil)
            }
           
            let removeAction = UIAction(title: "刪除", image: UIImage(systemName: "trash")) { action in
                self.alertDeleteItem()
            }
            
            let reportAction = UIAction(title: "檢舉", image: UIImage(systemName: "megaphone")) { action in
                self.revealBlockView()
            }
            return UIMenu(title: "", children: [editAction, removeAction, reportAction])
        }
    }
}
