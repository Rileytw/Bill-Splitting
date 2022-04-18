//
//  SubscriptionManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/18.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class SubscriptionManager {
    static var shared = SubscriptionManager()
    lazy var db = Firestore.firestore()
    
    func addSubscriptionData(groupId: String, itemName: String, paidUser: String, paidPrice: Double, createdTime: Double, completion: @escaping (String) -> Void) {
        let ref = db.collection(FireBaseCollection.subscription.rawValue).document()
        
        let subscriptionData = Subscription(doucmentId: "\(ref.documentID)", groupId: groupId, createdTime: createdTime, itemName: itemName, paidUser: paidUser, paidPrice: paidPrice)
        do {
            try db.collection(FireBaseCollection.subscription.rawValue).document("\(ref.documentID)").setData(from: subscriptionData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func addSubscriptionInvolvedExpense(typeUserId: String, price: Double, documentId: String, createdTime: Double) {
        let involvedInfo = ExpenseInfo(userId: typeUserId, price: price, createdTime: createdTime, itemId: documentId)
        
        do {
            try db.collection(FireBaseCollection.subscription.rawValue).document(documentId).collection("involvedInfo").document().setData(from: involvedInfo)
        } catch {
            print(error)
        }
    }

}
