//
//  ItermManager.swift
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
    
    func addItemData(groupId: String, itemName: String, itemDescription: String?, createdTime: Double, completion: @escaping (String) -> Void) {
        let ref = db.collection("item").document()
        
        let itemData = ItemData(groupId: groupId, itermName: itemName, itermId: "\(ref.documentID)", itermDescription: itemDescription, createdTime: createdTime)
        
        do {
            try db.collection("item").document("\(ref.documentID)").setData(from: itemData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func fetchGroupItemData(groupId: String, completion: @escaping ItemDataResponse) {
        db.collection("item").whereField("group", isEqualTo: groupId).getDocuments() { (querySnapshot, error) in
            
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
    
    func addPaidInfo(paidUserId: String, price: Double) {
        addItemExpenseInfo(typeUserId: paidUserId, collection: ItemExpenseType.paidInfo, price: price)
    }
    
    func addInvolvedInfo(involvedUserId: String, price: Double) {
        addItemExpenseInfo(typeUserId: involvedUserId, collection: ItemExpenseType.involvedInfo, price: price)
    }
    
    private func addItemExpenseInfo(typeUserId: String, collection: ItemExpenseType, price: Double) {
        let involvedInfo = ExpenseInfo(userId: typeUserId, price: price)
        
        do {
            try db.collection("item").document().collection(collection.rawValue).document().setData(from: involvedInfo)
        } catch {
            print(error)
        }
    }
}
