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
    
    func addSubscriptionData(groupId: String, itemName: String, paidUser: String, paidPrice: Double, startedTime: Double, endedTime: Double, cycle: Int, completion: @escaping (String) -> Void) {
        let ref = db.collection(FireBaseCollection.subscription.rawValue).document()
        
        let subscriptionData = Subscription(doucmentId: "\(ref.documentID)",
                                            groupId: groupId,
                                            startTime: startedTime,
                                            endTime: endedTime,
                                            itemName: itemName,
                                            paidUser: paidUser,
                                            paidPrice: paidPrice,
                                            cycle: cycle)
        do {
            try db.collection(FireBaseCollection.subscription.rawValue).document("\(ref.documentID)").setData(from: subscriptionData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func addSubscriptionInvolvedExpense(involvedUserId: String, price: Double, documentId: String) {
        let involvedInfo = SubscriptionMember(documentId: documentId, involvedUser: involvedUserId, involvedPrice: price)
        
        do {
            try db.collection(FireBaseCollection.subscription.rawValue).document(documentId).collection("involvedInfo").document().setData(from: involvedInfo)
        } catch {
            print(error)
        }
    }

}
