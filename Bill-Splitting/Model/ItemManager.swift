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
    
    func listenGroupItemData(groupId: String, completion: @escaping ItemDataResponse) {
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
    
    func fetchGroupItemData(groupId: String, completion: @escaping ItemDataResponse) {
        db.collection("item").whereField("groupId", isEqualTo: groupId).order(by: "createdTime", descending: true).getDocuments { (querySnapshot, error) in
            
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
    
    func listenForItems(itemId: String, completion: @escaping () -> Void) {
        db.collection("item").document(itemId)
            .collection("involvedInfo")
            .whereField("itemId", isEqualTo: itemId)
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
    
    func fetchItem(itemId: String, completion: @escaping (Result<ItemData, Error>) -> Void) {
        db.collection(FirebaseCollection.item.rawValue).document(itemId).addSnapshotListener { (querySnapshot, error) in
            
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
    
    func fetchPaidItemExpense(itemId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemExpense(itemId: itemId, collection: ItemExpenseType.paidInfo.rawValue, completion: completion)
    }

    func fetchInvolvedItemExpense(itemId: String, completion: @escaping ExpenseInfoResponse) {
        fetchItemExpense(itemId: itemId, collection: ItemExpenseType.involvedInfo.rawValue, completion: completion)
    }
    
    private func fetchItemExpense(itemId: String, collection: String, completion: @escaping ExpenseInfoResponse) {
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
    
    func fetchPaidItemsExpense(itemsId: [String], completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
        fetchItemsExpense(itemsId: itemsId, collection: ItemExpenseType.involvedInfo.rawValue, completion: completion)
    }
    
    func fetchInvolvedItemsExpense(itemsId: [String], completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
        fetchItemsExpense(itemsId: itemsId, collection: ItemExpenseType.paidInfo.rawValue, completion: completion)
    }


    private func fetchItemsExpense(itemsId: [String], collection: String, completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
        var items: [[ExpenseInfo]] = []
        for item in itemsId {
            db.collection("item").document(item).collection(collection).order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
                
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
                    items.append(involvedItems)
                    completion(.success(items))
                }
            }
        }
    }
    
    func addPaidInfo(paidUserId: String, price: Double, itemId: String, createdTime: Double, completion: @escaping (Result<(), Error>) -> Void) {
        addItemExpenseInfo(typeUserId: paidUserId,
                           collection: ItemExpenseType.paidInfo,
                           price: price,
                           itemId: itemId,
                           createdTime: createdTime, completion: completion)
    }
    
    func addInvolvedInfo(involvedUserId: String, price: Double, itemId: String, createdTime: Double, completion: @escaping (Result<(), Error>) -> Void) {
        addItemExpenseInfo(typeUserId: involvedUserId,
                           collection: ItemExpenseType.involvedInfo,
                           price: price,
                           itemId: itemId,
                           createdTime: createdTime, completion: completion)
    }
    
    private func addItemExpenseInfo(typeUserId: String, collection: ItemExpenseType, price: Double, itemId: String, createdTime: Double, completion: @escaping (Result<(), Error>) -> Void) {
        let involvedInfo = ExpenseInfo(userId: typeUserId, price: price, createdTime: createdTime, itemId: itemId)
        
        do {
            try db.collection("item").document(itemId).collection(collection.rawValue).document().setData(from: involvedInfo)
            completion(.success(()))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    func deleteItem(itemId: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.item.rawValue).document(itemId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully removed!")
                completion(.success(()))
            }
        }
    }
    
    func addNotify(grpupId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let ref = db.collection("notification")
        ref.addDocument(data:[
                   "groupId": grpupId
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
    
    func listenForNotification(groupId: String, completion: @escaping () -> Void) {
        db.collection("notification").whereField("groupId", isEqualTo: groupId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshots \(error?.localizedDescription)")
                    return
                }
                print("groupId: \(snapshot.documents.map { $0.data() })")
                completion()
            }
    }
}
