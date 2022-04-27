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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getGroupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setAnimation()
        getGroupData()
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
                self?.getBetweenGroupsItems()
            case .failure(let error):
                print("Error decoding userData: \(error)")
            }
        }
    }

// MARK: - Get items from all groups
    func getBetweenGroupsItems() {
        for groupData in self.groups {
            ItemManager.shared.fetchGroupItemData(groupId: groupData.groupId) { [weak self] result in
                switch result {
                case .success(let items):
                    self?.itemData += items
                    
                case .failure(let error):
                    print("Error decoding userData: \(error)")
                    
                }
                // MARK: - Get subCollection of item collection
                self?.getItemExpense()
            }
        }
    }
    
    // MARK: - Use GCD group to get two collection data at same time
    func getItemExpense() {
        let group = DispatchGroup()
        
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        group.enter()
        firstQueue.async(group: group) {
            self.paidItem.removeAll()
            for item in self.itemData {
                ItemManager.shared.fetchPaidItemsExpense(itemId: item.itemId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.paidItem += items
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                    }
                }
            }
            group.leave()
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        secondQueue.async(group: group) {
            self.involvedItem.removeAll()
            for index in 0..<self.itemData.count {
                ItemManager.shared.fetchInvolvedItemsExpense(itemId: self.itemData[index].itemId) { [weak self] result in
                    switch result {
                    case .success(let items):
                        self?.involvedItem += items
                    case .failure(let error):
                        print("Error decoding userData: \(error)")
                    }
                }
            }
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            print("====paid:\(self.paidItem)")
            print("====paidCount:\(self.paidItem.count)")
            print("====count:\(self.itemData.count)")
            print("====involved:\(self.involvedItem)")
            print("====involvedCount:\(self.involvedItem.count)")
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
