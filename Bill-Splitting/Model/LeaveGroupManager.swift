//
//  LeaveGroup.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/18.
//

import UIKit

class LeaveGroupManager {
    
    static let shared = LeaveGroupManager()
    private(set) var isLeaveGroupSuccess: Bool = false
    
    func leaveGroup(groupId: String, currentUserId: String, completion: @escaping () -> Void) {
        
        let group = DispatchGroup()
        
        group.enter()
        
        DispatchQueue.global().async {
            GroupManager.shared.removeGroupMember(
                groupId: groupId, userId: currentUserId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isLeaveGroupSuccess = true
                    case .failure:
                        self?.isLeaveGroupSuccess = false
                    }
                    group.leave()
                }
        }
        
        group.enter()
        DispatchQueue.global().async {
            GroupManager.shared.removeGroupExpense(
                groupId: groupId, userId: currentUserId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isLeaveGroupSuccess = true
                    case .failure:
                        self?.isLeaveGroupSuccess = false
                    }
                    group.leave()
                }
        }
        
        group.enter()
        
        DispatchQueue.global().async {
            GroupManager.shared.addLeaveMember(
                groupId: groupId, userId: currentUserId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isLeaveGroupSuccess = true
                    case .failure:
                        self?.isLeaveGroupSuccess = false
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
}
