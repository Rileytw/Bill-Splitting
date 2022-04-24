//
//  GroupManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

typealias ExpenseInfoResponse = (Result<[ExpenseInfo], Error>) -> Void

class GroupManager {
    static var shared = GroupManager()
    lazy var db = Firestore.firestore()
    
    func addGroupData(name: String, description: String?, creator: String, type: Int, status: Int, member: [String], createdTime: Double, completion: @escaping (String) -> Void) {
        let ref = db.collection("group").document()
        
        let groupData = GroupData(groupId: "\(ref.documentID)", groupName: name, groupDescription: description, creator: creator, type: type, status: status, member: member, createdTime: createdTime)
        
        do {
            try db.collection("group").document("\(ref.documentID)").setData(from: groupData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func fetchGroups(userId: String, completion: @escaping (Result<[GroupData], Error>) -> Void) {
        db.collection("group").whereField("member", arrayContains: userId).whereField("status", isEqualTo: 0).order(by:"createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
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
        fetchItemsExpense(itemId: itemId, userId: userId, collection: ItemExpenseType.paidInfo.rawValue, completion: completion)
    }
    
    func fetchInvolvedItemsExpense(itemId: String, userId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemsExpense(itemId: itemId, userId: userId, collection: ItemExpenseType.involvedInfo.rawValue, completion: completion)
    }
    
    private func fetchItemsExpense(itemId: String, userId: String, collection: String, completion: @escaping ExpenseInfoResponse) {
        db.collection("item").document(itemId).collection(collection).whereField("userId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            
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
    
    func addMemberExpenseData(userId: String, allExpense: Double, groupId: String) {
        let expenseData = MemberExpense(userId: userId, allExpense: allExpense)
        
        do {
            try db.collection("group").document(groupId).collection("memberExpense").document(userId).setData(from: expenseData)
        } catch {
            print(error)
        }
    }
    
    func updateMemberExpense(userId: String, newExpense: Double, groupId: String) {
        let ref = db.collection("group").document()
        let memberExpenseRef = db.collection("group").document(groupId).collection("memberExpense").document(userId)
        
        memberExpenseRef.updateData([
            "allExpense": FieldValue.increment(newExpense)
        ])
    }
    
    func fetchMemberExpense(groupId: String, userId: String, completion: @escaping (Result<[MemberExpense], Error>) -> Void) {
        db.collection("group").document(groupId).collection("memberExpense").addSnapshotListener { (querySnapshot, error) in
            
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
    
    func listenForItems(groupId: String, completion: @escaping () -> Void) {
        db.collection("item")
            .whereField("groupId", isEqualTo: groupId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshots \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        print("New: \(diff.document.data())")
                        completion()
                        
                    }
                    if (diff.type == .modified) {
                        print("Modified: \(diff.document.data())")
                    }
                    if (diff.type == .removed) {
                        print("Removed: \(diff.document.data())")
                    }
                }
                
            }
    }
    
    func updateGroupStatus(groupId: String) {
        let groupRef = db.collection("group").document(groupId)
        
        groupRef.updateData([
            "status": 1
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func updateGroupData(groupId: String, groupName: String, groupDescription: String, memberName: [String]?) {
        let groupRef = db.collection(FireBaseCollection.group.rawValue).document(groupId)
        
        groupRef.updateData([
            "groupName": groupName,
            "groupDescription": groupDescription
            
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        guard let memberName = memberName else { return }

        for index in 0..<memberName.count {
            groupRef.updateData([
                "member": FieldValue.arrayUnion([memberName[index]])
            ])
        }
    }
}
