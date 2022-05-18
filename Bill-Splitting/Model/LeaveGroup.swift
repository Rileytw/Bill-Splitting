//
//  LeaveGroup.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/18.
//

import UIKit

class LeaveGroup {
    
    static let shared = LeaveGroup()
    
    func leaveGroup(groupId: String, currentUserId: String, view: UIView, completion: @escaping () -> Void) {
        
        var isLeaveGroupSuccess: Bool = false
        
        let group = DispatchGroup()
        let firstQueue = DispatchQueue(label: "firstQueue", qos: .default, attributes: .concurrent)
        
        group.enter()
        
        firstQueue.async(group: group) {
            GroupManager.shared.removeGroupMember(
                groupId: groupId, userId: currentUserId) { result in
                switch result {
                case .success:
                    isLeaveGroupSuccess = true
                case .failure:
                    isLeaveGroupSuccess = false
                }
                group.leave()
            }
        }
        
        let secondQueue = DispatchQueue(label: "secondQueue", qos: .default, attributes: .concurrent)
        group.enter()
        secondQueue.async(group: group) {
            GroupManager.shared.removeGroupExpense(
                groupId: groupId, userId: currentUserId) { result in
                switch result {
                case .success:
                    isLeaveGroupSuccess = true
                case .failure:
                    isLeaveGroupSuccess = false
                }
                group.leave()
            }
        }
       
        let thirdQueue = DispatchQueue(label: "thirdQueue", qos: .default, attributes: .concurrent)
        group.enter()
        
        thirdQueue.async(group: group) {
            GroupManager.shared.addLeaveMember(
                groupId: groupId, userId: currentUserId) { result in
                switch result {
                case .success:
                    isLeaveGroupSuccess = true
                case .failure:
                    isLeaveGroupSuccess = false
                }
                group.leave()
            }
        }
       
        group.notify(queue: DispatchQueue.main) {
            if isLeaveGroupSuccess == true {
                completion()
            } else {
                ProgressHUD.shared.view = view
                ProgressHUD.showFailure(text: "發生錯誤")
            }
        }
    }
}
