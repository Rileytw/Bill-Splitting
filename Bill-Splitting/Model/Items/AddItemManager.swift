//
//  AddItem.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/18.
//

import UIKit

class AddItemManager {
    static let shared = AddItemManager()
    
    private(set) var isDataUploadSucces: Bool = false
    
    func addItem(
        groupId: String, itemId: String,
        paidUserId: String, paidPrice: Double,
        involvedExpenseData: [ExpenseInfo], involvedPrice: [Double],
        completion: @escaping () -> Void ) {
            
            let group = DispatchGroup()
            
            group.enter()
            
            DispatchQueue.global().async {
                var paidItemExpense = ExpenseInfo()
                paidItemExpense.userId = paidUserId
                paidItemExpense.itemId = itemId
                paidItemExpense.price = paidPrice
                paidItemExpense.createdTime = Double(NSDate().timeIntervalSince1970)
                ItemManager.shared.addPaidInfo(paidExpenseInfo: paidItemExpense, itemId: itemId) { [weak self] result in
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
                    var inVolvedExpense = ExpenseInfo()
                    inVolvedExpense.userId = involvedExpenseData[user].userId
                    inVolvedExpense.itemId = itemId
                    inVolvedExpense.price = involvedPrice[user]
                    inVolvedExpense.createdTime = Double(NSDate().timeIntervalSince1970)
                    ItemManager.shared.addInvolvedInfo(
                        involvedExpenseInfo: inVolvedExpense,
                        itemId: itemId) { [weak self] result in
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
                
                group.enter()
                DispatchQueue.global().async {
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
    
    func addSettleUpItem(
        groupId: String, itemId: String,
        paidUserId: String, paidPrice: Double,
        involvedUserId: String, involvedPrice: Double,
        completion: @escaping () -> Void ) {
            let group = DispatchGroup()
            
            group.enter()
            
            DispatchQueue.global().async {
                var paidItemExpense = ExpenseInfo()
                paidItemExpense.userId = paidUserId
                paidItemExpense.itemId = itemId
                paidItemExpense.price = paidPrice
                paidItemExpense.createdTime = Double(NSDate().timeIntervalSince1970)
                ItemManager.shared.addPaidInfo(paidExpenseInfo: paidItemExpense, itemId: itemId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isDataUploadSucces = true
                    case .failure:
                        self?.isDataUploadSucces = false
                    }
                    group.leave()
                }
            }
            
            group.enter()
            DispatchQueue.global().async {
                var involvedItemExpense = ExpenseInfo()
                involvedItemExpense.userId = involvedUserId
                involvedItemExpense.itemId = itemId
                involvedItemExpense.price = involvedPrice
                involvedItemExpense.createdTime = Double(NSDate().timeIntervalSince1970)
                
                ItemManager.shared.addInvolvedInfo(
                    involvedExpenseInfo: involvedItemExpense,
                    itemId: itemId) { [weak self] result in
                        switch result {
                        case .success:
                            self?.isDataUploadSucces = true
                        case .failure:
                            self?.isDataUploadSucces = false
                        }
                        group.leave()
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
            
            group.enter()
            DispatchQueue.global().async {
                GroupManager.shared.updateMemberExpense(userId: involvedUserId,
                                                        newExpense: 0 - involvedPrice,
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
            
            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
}
