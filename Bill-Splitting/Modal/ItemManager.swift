//
//  ItermManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/13.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class ItemManager {
    static var shared = ItemManager()
    lazy var db = Firestore.firestore()
    
    func addItemData(groupId: String, itemId: String, itemName: String, itemDescription: String?, createdTime: Double) {
        let ref = db.collection("item").document()
        
        let itemData = ItemData(groupId: groupId, itermName: itemName, itermId:  "\(ref.documentID)", itermDescription: itemDescription, createdTime: createdTime)
        
        do {
            try db.collection("item").document().setData(from: itemData)
        } catch {
            print(error)
        }
    }
    
    func fetchGroupItemData(groupId: String, completion: @escaping (Result<[ItemData], Error>) -> Void) {
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
}
