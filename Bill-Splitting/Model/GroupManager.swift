//
//  GroupManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import AVFoundation
import Accelerate

typealias ExpenseInfoResponse = (Result<[ExpenseInfo], Error>) -> Void

class GroupManager {
    static var shared = GroupManager()
    lazy var database = Firestore.firestore()
    
    func addGroupData(group: GroupData, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = database.collection(FirebaseCollection.group.rawValue).document()
        
        var groupData = group
        groupData.groupId = "\(ref.documentID)"
        
        do {
            try database.collection(FirebaseCollection.group.rawValue)
                .document("\(ref.documentID)").setData(from: groupData)
            completion(.success("\(ref.documentID)"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchGroups(userId: String, status: Int, completion: @escaping (Result<[GroupData], Error>) -> Void) {
        database.collection(FirebaseCollection.group.rawValue)
            .whereField("member", arrayContains: userId)
            .whereField("status", isEqualTo: status)
            .order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                
                var groups = [GroupData]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let group = try document.data(as: GroupData.self, decoder: Firestore.Decoder()) {
                            groups.append(group)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(groups))
            }
        }
    }
    
    func fetchGroupsRealTime(userId: String, status: Int, completion: @escaping (Result<[GroupData], Error>) -> Void) {
        database.collection(FirebaseCollection.group.rawValue)
            .whereField("member", arrayContains: userId)
            .whereField("status", isEqualTo: status)
            .order(by: "createdTime", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                
                var groups = [GroupData]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let group = try document.data(as: GroupData.self, decoder: Firestore.Decoder()) {
                            groups.append(group)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(groups))
            }
        }
    }
    
    func fetchPaidItemsExpense(itemId: String, userId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemsExpense(itemId: itemId, userId: userId,
                          collection: ItemExpenseType.paidInfo.rawValue,
                          completion: completion)
    }
    
    func fetchInvolvedItemsExpense(itemId: String, userId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemsExpense(itemId: itemId, userId: userId,
                          collection: ItemExpenseType.involvedInfo.rawValue,
                          completion: completion)
    }
    
    private func fetchItemsExpense(itemId: String, userId: String,
                                   collection: String, completion: @escaping ExpenseInfoResponse) {
        database.collection(FirebaseCollection.item.rawValue)
            .document(itemId)
            .collection(collection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var involvedItems: [ExpenseInfo] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let item = try document.data(as: ExpenseInfo.self, decoder: Firestore.Decoder()) {
                            involvedItems.append(item)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(involvedItems))
            }
        }
    }
    
    func addMemberExpenseData(userId: String, allExpense: Double,
                              groupId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let expenseData = MemberExpense(userId: userId, allExpense: allExpense)
        
        do {
            try database.collection(FirebaseCollection.group.rawValue)
                .document(groupId)
                .collection("memberExpense")
                .document(userId)
                .setData(from: expenseData)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateMemberExpense(
        userId: String, newExpense: Double, groupId: String,
        completion: @escaping (Result<(), Error>) -> Void) {
        let memberExpenseRef = database.collection("group")
                .document(groupId).collection("memberExpense").document(userId)
        
        memberExpenseRef.updateData([
            "allExpense": FieldValue.increment(newExpense)
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchMemberExpense(groupId: String, members: [String],
                            completion: @escaping (Result<[MemberExpense], Error>) -> Void) {
        database.collection(FirebaseCollection.group.rawValue)
            .document(groupId)
            .collection("memberExpense")
            .whereField("userId", in: members)
            .addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var memberExpense: [MemberExpense] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let expense = try document.data(as: MemberExpense.self, decoder: Firestore.Decoder()) {
                            memberExpense.append(expense)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(memberExpense))
            }
        }
    }
   
    func fetchMemberExpenseForBlock(groupId: String, members: [String],
                                    completion: @escaping (Result<[MemberExpense], Error>) -> Void) {
        database.collection(FirebaseCollection.group.rawValue)
            .document(groupId).collection("memberExpense")
            .whereField("userId", in: members).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var memberExpense: [MemberExpense] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let expense = try document.data(as: MemberExpense.self, decoder: Firestore.Decoder()) {
                            memberExpense.append(expense)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(memberExpense))
            }
        }
    }
    
    func updateGroupStatus(groupId: String, comletion: @escaping (Result<(), Error>) -> Void) {
        let groupRef = database.collection(FirebaseCollection.group.rawValue).document(groupId)
        
        groupRef.updateData([
            "status": 1
        ]) { err in
            if let err = err {
                comletion(.failure(err))
            } else {
                comletion(.success(()))
            }
        }
    }
    
    func updateGroupData(groupId: String, groupName: String,
                         groupDescription: String, memberName: [String]?,
                         completion: @escaping (Result<(), Error>) -> Void) {
        let groupRef = database.collection(FirebaseCollection.group.rawValue).document(groupId)
        
        groupRef.updateData([
            "groupName": groupName,
            "groupDescription": groupDescription
            
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully updated")
                completion(.success(()))
            }
        }
        
        guard let memberName = memberName else { return }

        for index in 0..<memberName.count {
            groupRef.updateData([
                "member": FieldValue.arrayUnion([memberName[index]])
            ])
        }
    }
    
    func removeGroupMember(groupId: String, userId: String, completion: @escaping(Result<String, Error>) -> Void) {
        let groupRef = database.collection(FirebaseCollection.group.rawValue).document(groupId)

        groupRef.updateData([
                "member": FieldValue.arrayRemove([userId])
            ]) { err in
                if let err = err {
                    completion(.failure(err))
                } else {
                    completion(.success("success"))
                }
            }

        }
    
    func removeGroupExpense(groupId: String, userId: String, completion: @escaping(Result<String, Error>) -> Void) {
        database.collection(FirebaseCollection.group.rawValue)
            .document(groupId)
            .collection("memberExpense")
            .document(userId).delete { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success("success"))
            }
        }
    }
    
    func addLeaveMember(groupId: String, userId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let leaveMembersRef = database.collection(FirebaseCollection.group.rawValue).document(groupId)
        leaveMembersRef.updateData([
            "leaveMembers": FieldValue.arrayUnion([userId])
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    
    private(set) var isExpenseUpdateSucces: Bool = false
    
    func updatePersonalExpense(groupId: String, item: ItemData, completion: @escaping () -> Void) {
        guard let paidUserId = item.paidInfo?[0].userId,
              let paidPrice = item.paidInfo?[0].price
        else { return }
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            GroupManager.shared.updateMemberExpense(userId: paidUserId ,
                                                    newExpense: 0 - paidPrice,
                                                    groupId: groupId) { [weak self] result in
                switch result {
                case .success:
                    self?.isExpenseUpdateSucces = true
                case .failure:
                    self?.isExpenseUpdateSucces = false
                }
                group.leave()
            }
        }
       
        guard let involvedExpense = item.involedInfo else { return }

        for user in 0..<involvedExpense.count {
            group.enter()
            DispatchQueue.global().async {
                GroupManager.shared.updateMemberExpense(userId: involvedExpense[user].userId,
                                                        newExpense: involvedExpense[user].price,
                                                        groupId: groupId) { [weak self] result in
                    switch result {
                    case .success:
                        self?.isExpenseUpdateSucces = true
                    case .failure:
                        self?.isExpenseUpdateSucces = false
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
