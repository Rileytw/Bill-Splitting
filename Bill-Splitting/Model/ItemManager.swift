//
//  ItemManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

enum ItemExpenseType: String {
    case paidInfo
    case involvedInfo
}

typealias ItemDataResponse = (Result<[ItemData], Error>) -> Void

class ItemManager {
    static var shared = ItemManager()
    lazy var db = Firestore.firestore()
    
    func addItemData(groupId: String, itemName: String, itemDescription: String?, createdTime: Double, itemImage: String?, completion: @escaping (String) -> Void) {
        let ref = db.collection("item").document()
        
        let itemData = ItemData(groupId: groupId, itemName: itemName, itemId: "\(ref.documentID)", itemDescription: itemDescription, createdTime: createdTime, itemImage: itemImage)
        
        do {
            try db.collection("item").document("\(ref.documentID)").setData(from: itemData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func fetchGroupItemData(groupId: String, completion: @escaping ItemDataResponse) {
        db.collection("item").whereField("groupId", isEqualTo: groupId).order(by: "createdTime", descending: true).addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var items = [ItemData]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let item = try document.data(as: ItemData.self, decoder: Firestore.Decoder()) {
                            items.append(item)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(items))
            }
        }
    }
    
    func fetchItem(itemId: String, completion: @escaping (Result<ItemData, Error>) -> Void) {
        db.collection(FireBaseCollection.item.rawValue).document(itemId).getDocument { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                var items: ItemData?
                do {
                    if let item = try querySnapshot?.data(as: ItemData.self, decoder: Firestore.Decoder()) {
                        items = item
                        guard let items = items else { return }
                        completion(.success(items))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchPaidItemsExpense(itemId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemsExpense(itemId: itemId, collection: ItemExpenseType.paidInfo.rawValue, completion: completion)
    }

    func fetchInvolvedItemsExpense(itemId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemsExpense(itemId: itemId, collection: ItemExpenseType.involvedInfo.rawValue, completion: completion)
    }
    
    private func fetchItemsExpense(itemId: String, collection: String, completion: @escaping ExpenseInfoResponse) {
        db.collection("item").document(itemId).collection(collection).order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
            
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
    
    func addPaidInfo(paidUserId: String, price: Double, itemId: String, createdTime: Double) {
        addItemExpenseInfo(typeUserId: paidUserId,
                           collection: ItemExpenseType.paidInfo,
                           price: price,
                           itemId: itemId,
                           createdTime: createdTime)
    }
    
    func addInvolvedInfo(involvedUserId: String, price: Double, itemId: String, createdTime: Double) {
        addItemExpenseInfo(typeUserId: involvedUserId,
                           collection: ItemExpenseType.involvedInfo,
                           price: price,
                           itemId: itemId,
                           createdTime: createdTime)
    }
    
    private func addItemExpenseInfo(typeUserId: String, collection: ItemExpenseType, price: Double, itemId: String, createdTime: Double) {
        let involvedInfo = ExpenseInfo(userId: typeUserId, price: price, createdTime: createdTime, itemId: itemId)
        
        do {
            try db.collection("item").document(itemId).collection(collection.rawValue).document().setData(from: involvedInfo)
        } catch {
            print(error)
        }
    }
    
    func deleteItem(itemId: String) {
        db.collection(FireBaseCollection.item.rawValue).document(itemId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
