//
//  ItemDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var itemId: String?
    var item: ItemData?
    var groupData: GroupData?
    var userData: [UserData] = []
    var tableView = UITableView()
    var paidUser: [UserData] = []
    var involvedUser: [UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElementsStyle.styleBackground(view)
        addMenu()
        setTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getItemData()
    }
    
    func addMenu() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        let interaction = UIContextMenuInteraction(delegate: self)
        button.addInteraction(interaction)
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
//            print("involedUser:\(self.involvedUser) ")
        }
    }
    
    func getPayUser() {
        paidUser = userData.filter { $0.userId == item?.paidInfo?[0].userId }
    }
    
    func getInvolvedUser() {
        guard let involvedExpense = item?.involedInfo else {
            return
        }
        for index in 0..<involvedExpense.count {
            involvedUser += userData.filter { $0.userId == involvedExpense[index].userId }
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
                print("eeeee")
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
                print("ddddd")
                self.deleteItem()
                self.navigationController?.popViewController(animated: true)
            }
            return UIMenu(title: "", children: [editAction, removeAction])
        }
    }
}
