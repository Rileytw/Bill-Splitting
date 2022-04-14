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
    var memberName: [String]? = []
    var userData: [UserData]? = []
    
    var paidItem: [[ExpenseInfo]] = []
    var involvedItem: [[ExpenseInfo]] = []
    var itemId: String? = "rjzUwVdigPGUnpy4yvIf"
    var expense: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGroupDetailView()
        
//        GroupManager.shared.listenForItems(groupId: groupData?.groupId ?? "") {
//            self.countPersonalExpense()
//            print("Listen~~~~~~~~~~~~~~~~~~~")
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        groupData?.member.forEach {
            member in
            UserManager.shared.fetchUserData(friendId: member) {
                [weak self] result in
                switch result {
                case .success(let userData):
                    self?.memberName?.append(userData.userName)
                    self?.userData?.append(userData)
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                }
            }
        }
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
//        ItemManager.shared.addItemData(groupId: groupData?.groupId ?? "", itemName: "飲料", itemDescription: "", createdTime: Double(NSDate().timeIntervalSince1970)) {
//            itemId in
//            self.itemId = itemId
//            self.countPersonalExpense()
//        }
        
//        countPersonalExpense()
        //        ItemManager.shared.addPaidInfo(paidUserId: userId, price: 100)
        
        let storyBoard = UIStoryboard(name: "Groups", bundle: nil)
        guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: String(describing: AddItemViewController.self)) as? AddItemViewController else { return }
        addItemViewController.memberId = groupData?.member
//        addItemViewController.memberName = memberName
        addItemViewController.memberData = userData
        addItemViewController.groupData = groupData
        self.present(addItemViewController, animated: true, completion: nil)
    }
    
    //    func setItemTableView() {
    //
    //    }
    
//    Listen itemCollection, if changed, call function
//    func countPersonalExpense() {
//        let group = DispatchGroup()
//
//        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
//        self.groupData?.member.forEach {
//            member in
//            group.enter()
//            firstQueue.async(group: group) {
//                GroupManager.shared.fetchPaidItemsExpense(itemId: self.itemId ?? "", userId: member) {
//                    [weak self] result in
//                    switch result {
//                    case .success(let paidItems):
//                        self?.paidItem.append(paidItems)
//                        group.leave()
//                    case .failure(let error):
//                        print("Error decoding userData: \(error)")
//                        group.leave()
//                    }
//                }
//                //                group.leave()
//            }
//        }
//
//        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
//        self.groupData?.member.forEach {
//            member in
//            group.enter()
//            secondQueue.async(group: group) {
//                GroupManager.shared.fetchInvolvedItemsExpense(itemId: self.itemId ?? "", userId: member) {
//                    [weak self] result in
//                    switch result {
//                    case .success(let involvedItems):
//                        self?.involvedItem.append(involvedItems)
//                        group.leave()
//                    case .failure(let error):
//                        print("Error decoding userData: \(error)")
//                        group.leave()
//                    }
//                }
//                //                group.leave()
//            }
//        }
//
//        group.notify(queue: DispatchQueue.main) {
//            guard let groupData = self.groupData else { return }
//
//            let paidItem = self.paidItem.flatMap { (item) -> [ExpenseInfo] in
//                return item
//            }
//            let involvedItem = self.involvedItem.flatMap {
//                (item) -> [ExpenseInfo] in
//                    return item
//            }
//
//            paidItem.forEach {
//                item in
//                GroupManager.shared.updateMemberExpense(userId: item.userId, newExpense: item.price, groupId: groupData.groupId)
//                print("itemprice: \(item.price)")
//                print("userId:\(item.userId)")
//            }
//
//            involvedItem.forEach {
//                item in
//                GroupManager.shared.updateMemberExpense(userId: item.userId, newExpense: 0 - item.price, groupId: groupData.groupId)
//                print("itemprice: \(0 - item.price)")
//                print("userId:\(item.userId)")
//            }
////
////            print("===========paid:\(paidItem)")
////            print("===========involved:\(involvedItem)")
////
//        }
//    }
    
}
