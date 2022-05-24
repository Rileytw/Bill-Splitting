//
//  AddItem.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/18.
//

import UIKit

class AddItem {
    static let shared = AddItem()
    
    private(set) var isDataUploadSucces: Bool = false
    
    func addItem(groupId: String, itemId: String, paidUserId: String, paidPrice: Double, involvedExpenseData: [ExpenseInfo], involvedPrice: [Double], completion: @escaping () -> Void ) {
        
        let group = DispatchGroup()

        group.enter()

        DispatchQueue.global().async {
            ItemManager.shared.addPaidInfo(paidUserId: paidUserId, price: paidPrice, itemId: itemId,
                createdTime: Double(NSDate().timeIntervalSince1970)) { [weak self] result in
                switch result {
                case .success:
                    self?.isDataUploadSucces = true
                case .failure:
                    self?.isDataUploadSucces = false
                }
                group.leave()
            }
        }

        for user in 0..<involvedExpenseData.count {
            group.enter()
            DispatchQueue.global().async {
                ItemManager.shared.addInvolvedInfo(involvedUserId: involvedExpenseData[user].userId,
                                                   price: involvedPrice[user],
                                                   itemId: itemId,
                                                   createdTime: Double(NSDate().timeIntervalSince1970)
                ) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isDataUploadSucces = true
                    case .failure:
                        self?.isDataUploadSucces = false
                    }
                    group.leave()
                }
            }
        }

        group.enter()
        DispatchQueue.global().async {
            GroupManager.shared.updateMemberExpense(
                userId: paidUserId,
                newExpense: paidPrice,
                groupId: groupId) { [weak self] result in
                switch result {
                case .success:
                    self?.isDataUploadSucces = true
                case .failure:
                    self?.isDataUploadSucces = false
                }
                group.leave()
            }
        }
        
        for user in 0..<involvedExpenseData.count {
            let fourthQueue = DispatchQueue(label: "fourthQueue", qos: .default, attributes: .concurrent)
            group.enter()
            fourthQueue.async(group: group) {
                GroupManager.shared.updateMemberExpense(userId: involvedExpenseData[user].userId,
                                                        newExpense: 0 - involvedPrice[user],
                                                        groupId: groupId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isDataUploadSucces = true
                    case .failure:
                        self?.isDataUploadSucces = false
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}
