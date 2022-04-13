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
    var paidItem: [[ExpenseInfo]] = []
    var involvedItem: [[ExpenseInfo]] = []
    
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
        countPersonalExpense()
        //        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "", itemName: "飲料", itemDescription: "", createdTime: Double(NSDate().timeIntervalSince1970))
        //        ItemManager.shared.addPaidInfo(paidUserId: userId, price: 100)
        
    }
    
    
    //    func setItemTableView() {
    //
    //    }
    
    func countPersonalExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        //        group.enter()
        //        firstQueue.async(group: group) {
        self.groupData?.member.forEach {
            member in
            group.enter()
            firstQueue.async(group: group) {
                GroupManager.shared.fetchPaidItemsExpense(groupId: self.groupData?.groupId ?? "", userId: member) {
                    [weak self] result in
                    switch result {
                    case .success(let paidItems):
                        self?.paidItem.append(paidItems)
                        group.leave()
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        group.leave()
                    }
                }
                //                group.leave()
            }
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        //        group.enter()
        //        secondQueue.async(group: group) {
        self.groupData?.member.forEach {
            member in
            group.enter()
            secondQueue.async(group: group) {
                GroupManager.shared.fetchInvolvedItemsExpense(groupId: self.groupData?.groupId ?? "", userId: member) {
                    [weak self] result in
                    switch result {
                    case .success(let involvedItems):
                        self?.involvedItem.append(involvedItems)
                        group.leave()
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        group.leave()
                    }
                }
                //                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            
            let paidItem = self.paidItem.flatMap { (item) -> [ExpenseInfo] in
                return item
            }
            let involvedItem = self.involvedItem.flatMap {
                (item) -> [ExpenseInfo] in
                    return item
            }
            print("===========paid:\(paidItem)")
            print("===========involved:\(involvedItem)")
            
        }
    }
    
}
