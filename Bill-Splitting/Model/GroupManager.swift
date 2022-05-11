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
    lazy var db = Firestore.firestore()
    
    func addGroupData(name: String, description: String?, creator: String, type: Int, status: Int, member: [String], createdTime: Double, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = db.collection("group").document()
        
        let groupData = GroupData(groupId: "\(ref.documentID)", groupName: name, groupDescription: description, creator: creator, type: type, status: status, member: member, createdTime: createdTime)
        
        do {
            try db.collection("group").document("\(ref.documentID)").setData(from: groupData)
            completion(.success("\(ref.documentID)"))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    func fetchGroups(userId: String, status: Int, completion: @escaping (Result<[GroupData], Error>) -> Void) {
        db.collection("group").whereField("member", arrayContains: userId).whereField("status", isEqualTo: status).order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
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
        db.collection("group").whereField("member", arrayContains: userId).whereField("status",
                                                                                      isEqualTo: status).order(by: "createdTime",
                                                                                                               descending: true).addSnapshotListener() { (querySnapshot, error) in
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
    
    func addMemberExpenseData(userId: String, allExpense: Double, groupId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let expenseData = MemberExpense(userId: userId, allExpense: allExpense)
        
        do {
            try db.collection("group").document(groupId).collection("memberExpense").document(userId).setData(from: expenseData)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    func updateMemberExpense(userId: String, newExpense: Double, groupId: String) {
        let ref = db.collection("group").document()
        let memberExpenseRef = db.collection("group").document(groupId).collection("memberExpense").document(userId)
        
        memberExpenseRef.updateData([
            "allExpense": FieldValue.increment(newExpense)
        ])
    }
    
// MARK: - addSnapshotListener can't listen to new documents
    func fetchMemberExpense(groupId: String, members: [String], completion: @escaping (Result<[MemberExpense], Error>) -> Void) {
        db.collection("group").document(groupId).collection("memberExpense").whereField("userId", in: members).addSnapshotListener { (querySnapshot, error) in
            
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
   
    func fetchMemberExpenseForBlock(groupId: String, members: [String], completion: @escaping (Result<[MemberExpense], Error>) -> Void) {
        db.collection("group").document(groupId).collection("memberExpense").whereField("userId", in: members).getDocuments { (querySnapshot, error) in
            
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
        let groupRef = db.collection(FirebaseCollection.group.rawValue).document(groupId)
        
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
    
    func removeGroupMember(groupId: String, userId: String, completion: @escaping(Result<String, Error>) -> Void) {
        let groupRef = db.collection(FirebaseCollection.group.rawValue).document(groupId)

        groupRef.updateData([
                "member": FieldValue.arrayRemove([userId])
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                    completion(.failure(err))
                } else {
                    print("Document successfully updated")
                    completion(.success("success"))
                }
            }

        }
    
    func removeGroupExpense(groupId: String, userId: String, completion: @escaping(Result<String, Error>) -> Void) {
        db.collection(FirebaseCollection.group.rawValue).document(groupId).collection("memberExpense").document(userId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully removed!")
                completion(.success("success"))
            }
        }
    }
    
    func addLeaveMember(groupId: String, userId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let leaveMembersRef = db.collection(FirebaseCollection.group.rawValue).document(groupId)
        leaveMembersRef.updateData([
            "leaveMembers": FieldValue.arrayUnion([userId])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully updated")
                completion(.success(()))
            }
        }
    }
}
