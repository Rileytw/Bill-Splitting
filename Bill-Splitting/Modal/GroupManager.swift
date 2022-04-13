//
//  GroupManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

enum Grouptype: Int {
    case personal = 0
    case group = 1
}

typealias ExpenseInfoResponse = (Result<[ExpenseInfo], Error>) -> Void

class GroupManager {
    static var shared = GroupManager()
    lazy var db = Firestore.firestore()
    
    func addGroupData(name: String, description: String?, creator: String, type: Int, status: Int, member: [String], completion: @escaping (String) -> Void) {
        let ref = db.collection("group").document()
        
        let groupData = GroupData(groupId: "\(ref.documentID)", groupName: name, goupDescription: description, creator: creator, type: type, status: status, member: member)
        
        do {
            try db.collection("group").document("\(ref.documentID)").setData(from: groupData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func fetchGroups(userId: String, completion: @escaping (Result<[GroupData], Error>) -> Void) {
        db.collection("group").whereField("member", arrayContains: userId).getDocuments() { (querySnapshot, error) in
            
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
    
    func updateMemberExpense(userId: String, newExpense: Double) {
        let ref = db.collection("group").document()
        let memberExpenseRef = db.collection("group").document("\(ref.documentID)").collection("memberExpense").document(userId)
        
        memberExpenseRef.updateData([
            "allExpense": FieldValue.increment(newExpense)
        ])
    }
}
