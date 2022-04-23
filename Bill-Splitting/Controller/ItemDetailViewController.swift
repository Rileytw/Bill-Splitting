//
//  ItemDetailViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/22.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var itemId: String?
    var item: ItemData? {
        didSet {
            tableView.reloadData()
        }
    }
    var groupName: String?
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMenu()
        setTableView()
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
        ItemManager.shared.fetchPaidItemsExpense(itemId: self.itemId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                self?.item?.paidInfo = items
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
        
        ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.itemId ?? "") { [weak self] result in
            switch result {
            case .success(let items):
                self?.item?.involedInfo = items
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
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
            
            detailCell.createDetailCell(group: groupName ?? "",
                                        item: item.itemName,
                                        time: item.createdTime,
                                        paidPrice: item.paidInfo?[0].price ?? 0,
                                        description: item.itemDescription,
                                        image: item.itemImage)
            
            return detailCell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: ItemMemberTableViewCell.self),
                for: indexPath
            )
            guard let memberCell = cell as? ItemMemberTableViewCell else { return cell }
            
           
            
            return memberCell
        }
    }
}

extension ItemDetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
           
            let editAction = UIAction(title: "編輯", image: UIImage(systemName: "pencil")) { action in
                print("eeeee")
            }
           
            let removeAction = UIAction(title: "刪除", image: UIImage(systemName: "trash")) { action in
                print("ddddd")
            }
            return UIMenu(title: "", children: [editAction, removeAction])
        }
    }
}
