//
//  DeleteItem.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/24.
//

import UIKit

class DeleteItemManager {
    static let shared = DeleteItemManager()
    
    private(set) var isItemDeleteSucces: Bool = false
    
    func deleteItem(groupId: String,
                    itemId: String,
                    item: ItemData,
                    completion: @escaping () -> Void) {
        let paidUserId = item.paidInfo?[0].userId ?? ""
        let paidPrice = item.paidInfo?[0].price ?? 0
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                    newExpense: 0 - paidPrice,
                                                    groupId: groupId) { [weak self] result in
                switch result {
                case .success:
                    self?.isItemDeleteSucces = true
                case .failure:
                    self?.isItemDeleteSucces = false
                }
                group.leave()
            }
        }
        
        guard let involedInfo = item.involedInfo else { return }
        for user in 0..<involedInfo.count {
            group.enter()
            DispatchQueue.global().async {
                GroupManager.shared.updateMemberExpense(userId: involedInfo[user].userId,
                                                        newExpense: involedInfo[user].price,
                                                        groupId: groupId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isItemDeleteSucces = true
                        group.leave()
                    case .failure:
                        self?.isItemDeleteSucces = false
                        group.leave()
                    }
                }
            }
        }
        
        group.enter()
        DispatchQueue.global().async {
            ItemManager.shared.deleteItem(itemId: itemId) { [weak self] result in
                switch result {
                case .success:
                    self?.isItemDeleteSucces = true
                case .failure:
                    self?.isItemDeleteSucces = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}
    
