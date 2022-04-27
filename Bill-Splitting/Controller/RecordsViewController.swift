//
//  RecordsViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/24.
//

import UIKit
import Lottie

class RecordsViewController: UIViewController {
    
    private var animationView = AnimationView()
    var groups: [GroupData] = []
    var itemData: [ItemData] = []
    var paidItem: [ExpenseInfo] = []
    var involvedItem: [ExpenseInfo] = []
    var personalPaid: [ExpenseInfo] = []
    var personalInvolved: [ExpenseInfo] = []
    var allPersonalItem: [ExpenseInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getGroupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setAnimation()
//        getGroupData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        animationView.stop()
    }
    // MARK: - Get groups data first
    func getGroupData() {
        GroupManager.shared.fetchGroups(userId: userId, status: 0) { [weak self] result in
            switch result {
            case .success(let groups):
                self?.groups = groups
                // MARK: - Use group data to get item data from each group
                self?.getGroupsItemExpense()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }

// MARK: - Get items from all groups
    
//  Replace by getGroupsItemExpense()
//    func getBetweenGroupsItems() {
//        paidItem.removeAll()
//        involvedItem.removeAll()
//        for groupData in self.groups {
//            ItemManager.shared.fetchGroupItemData(groupId: groupData.groupId) { [weak self] result in
//                switch result {
//                case .success(let items):
//                    self?.itemData += items
//                case .failure(let error):
//                    print("Error decoding userData: \(error)")
//
//                }
//                // MARK: - Get subCollection of item collection
////                self?.getItemExpense()
//            }
//        }
//    }
    
    func getGroupsItemExpense() {
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "serialQueue", qos: .default, attributes: .concurrent)
        
        queue.async {
            for groupData in self.groups {
                ItemManager.shared.fetchGroupItemData(groupId: groupData.groupId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.itemData += items
                        semaphore.signal()
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                        
                    }
                }
                semaphore.wait()
            }
            self.getItemExpense()
        }
    }
    
    // MARK: - Use GCD group to get two collection data at same time
    func getItemExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
            self.paidItem.removeAll()
            for item in self.itemData {
                group.enter()
                firstQueue.async(group: group) {
                    ItemManager.shared.fetchPaidItemsExpense(itemId: item.itemId) { [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.paidItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                        }
                    }

                }
            }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
            self.involvedItem.removeAll()
            for index in 0..<self.itemData.count {
                group.enter()
                secondQueue.async(group: group) {
                    ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.itemData[index].itemId) {
                        [weak self] result in
                        switch result {
                        case .success(let items):
                            self?.involvedItem += items
                            group.leave()
                        case .failure(let error):
                            print("Error decoding userData: \(error)")
                        }
                    }
                }
            }
        group.notify(queue: DispatchQueue.main) {
//            print("====paid:\(self.paidItem)")
//            print("====paidCount:\(self.paidItem.count)")
//            print("====count:\(self.itemData.count)")
//            print("====involved:\(self.involvedItem)")
//            print("====involvedCount:\(self.involvedItem.count)")
//
            self.personalPaid = self.paidItem.filter { $0.userId == userId }
            self.personalInvolved = self.involvedItem.filter { $0.userId == userId }
            
            for index in 0..<self.personalInvolved.count {
                self.personalInvolved[index].price = 0 - self.personalInvolved[index].price
            }
            print("====involved:\(self.personalInvolved)")
            
            self.allPersonalItem = self.personalPaid + self.personalInvolved
            self.allPersonalItem.sort { $0.createdTime ?? 0 > $1.createdTime ?? 0 }
            self.allPersonalItem = Array(self.allPersonalItem.prefix(5))
            print("====all:\(self.allPersonalItem)")
            print("====allCount:\(self.allPersonalItem.count)")
        }
    }
    
    func setAnimation() {
        animationView = .init(name: "list")
        
        animationView.frame = view.bounds
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.75
        view.addSubview(animationView)
        animationView.play()
    }
    
}
