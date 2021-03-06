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
    lazy var database = Firestore.firestore()
    
    func addItemData(itemData: ItemData, completion: @escaping (String) -> Void) {
        let ref = database.collection(FirebaseCollection.item.rawValue).document()
        
        var updateItem = itemData
        updateItem.itemId = "\(ref.documentID)"
        
        do {
            try database.collection(FirebaseCollection.item.rawValue)
                .document("\(ref.documentID)").setData(from: updateItem)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func listenGroupItemData(groupId: String, completion: @escaping ItemDataResponse) {
        database.collection(FirebaseCollection.item.rawValue)
            .whereField("groupId", isEqualTo: groupId)
            .order(by: "createdTime", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                
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
        database.collection(FirebaseCollection.item.rawValue)
            .whereField("groupId", isEqualTo: groupId)
            .order(by: "createdTime", descending: true)
            .getDocuments { (querySnapshot, error) in
                
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
        database.collection(FirebaseCollection.item.rawValue).document(itemId)
            .collection(FirebaseCollection.involvedInfo.rawValue)
            .whereField("itemId", isEqualTo: itemId)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshots \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        completion()
                    }
                }
            }
    }
    
    func fetchItem(itemId: String, completion: @escaping (Result<ItemData, Error>) -> Void) {
        database.collection(FirebaseCollection.item.rawValue)
            .document(itemId).addSnapshotListener { (querySnapshot, error) in
                
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
        database.collection(FirebaseCollection.item.rawValue)
            .document(itemId)
            .collection(collection)
            .order(by: "createdTime", descending: true)
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
    
    func fetchPaidItemsExpense(itemsId: [String], completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
        fetchItemsExpense(itemsId: itemsId, collection: ItemExpenseType.involvedInfo.rawValue, completion: completion)
    }
    
    func fetchInvolvedItemsExpense(itemsId: [String], completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
        fetchItemsExpense(itemsId: itemsId, collection: ItemExpenseType.paidInfo.rawValue, completion: completion)
    }
    
    private func fetchItemsExpense(
        itemsId: [String],
        collection: String,
        completion: @escaping (Result<[[ExpenseInfo]], Error>) -> Void) {
            var items: [[ExpenseInfo]] = []
            for item in itemsId {
                database.collection(FirebaseCollection.item.rawValue)
                    .document(item)
                    .collection(collection)
                    .order(by: "createdTime", descending: true)
                    .getDocuments { (querySnapshot, error) in
                        
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            
                            var involvedItems: [ExpenseInfo] = []
                            
                            for document in querySnapshot!.documents {
                                
                                do {
                                    if let item = try document.data(
                                        as: ExpenseInfo.self,
                                        decoder: Firestore.Decoder()) {
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
    
    func addPaidInfo(
        paidExpenseInfo: ExpenseInfo,
        itemId: String,
        completion: @escaping (Result<(), Error>) -> Void) {
            addItemExpenseInfo(
                collection: ItemExpenseType.paidInfo,
                expenseInfo: paidExpenseInfo,
                itemId: itemId,
                completion: completion)
        }
    
    func addInvolvedInfo(
        involvedExpenseInfo: ExpenseInfo,
        itemId: String,
        completion: @escaping (Result<(), Error>) -> Void) {
            addItemExpenseInfo(
                collection: ItemExpenseType.involvedInfo,
                expenseInfo: involvedExpenseInfo,
                itemId: itemId,
                completion: completion)
        }
    
    private func addItemExpenseInfo(
        collection: ItemExpenseType,
        expenseInfo: ExpenseInfo,
        itemId: String,
        completion: @escaping (Result<(), Error>) -> Void) {
            let involvedInfo = expenseInfo
            
            do {
                try database.collection(FirebaseCollection.item.rawValue)
                    .document(itemId).collection(collection.rawValue)
                    .document().setData(from: involvedInfo)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    
    func deleteItem(itemId: String, completion: @escaping (Result<(), Error>) -> Void) {
        database.collection(FirebaseCollection.item.rawValue).document(itemId).delete { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func addNotify(grpupId: String, completion: @escaping (Result<(), Error>) -> Void) {
        let ref = database.collection(FirebaseCollection.notification.rawValue)
        ref.addDocument(data: [
            "groupId": grpupId
        ]) { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func listenForNotification(groupId: String, completion: @escaping () -> Void) {
        database.collection(FirebaseCollection.notification.rawValue)
            .whereField("groupId", isEqualTo: groupId)
            .addSnapshotListener { querySnapshot, _ in
                guard querySnapshot != nil else { return }
                completion()
            }
    }
}
