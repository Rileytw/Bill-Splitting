//
//  MultipleUsersGrouplViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit

class MultipleUsersGrouplViewController: UIViewController {
    
    let groupDetailView = GroupDetailView(frame: CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 200))
//    let itemTableView = UITableView()
    var groupData: GroupData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGroupDetailView()
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
        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "", itemName: "飲料", itemDescription: "", createdTime: Double(NSDate().timeIntervalSince1970))
//        ItemManager.shared.addPaidInfo(paidUserId: userId, price: 100)

    }
    

//    func setItemTableView() {
//
//    }
    
}
