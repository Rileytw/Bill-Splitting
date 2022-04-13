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

class GroupManager {
    static var shared = GroupManager()
    lazy var db = Firestore.firestore()
    
    func addGroupData(name: String, description: String?, creator: String, type: Int, status: Int, member: [String]) {
        let ref = db.collection("group").document()
        
        let groupData = GroupData(groupId: "\(ref.documentID)", groupName: name, goupDescription: description, creator: creator, type: type, status: status, member: member)
        
        do {
            try db.collection("group").document("\(ref.documentID)").setData(from: groupData)
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
    
    func fetchPaidItemsExpense(groupId: String, userId: String, completion: @escaping (Result<[ExpenseInfo], Error>) -> Void) {
        db.collection("item").document("pPPogrv25nTG3YYs7zVp").collection("paidInfo").whereField("userId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var paidItems: [ExpenseInfo] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let item = try document.data(as: ExpenseInfo.self, decoder: Firestore.Decoder()) {
                            paidItems.append(item)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(paidItems))
            }
        }
    }

    func fetchInvolvedItemsExpense(groupId: String, userId: String, completion: @escaping (Result<[ExpenseInfo], Error>) -> Void) {
        db.collection("item").document("pPPogrv25nTG3YYs7zVp").collection("involvedInfo").whereField("userId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            
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

}
