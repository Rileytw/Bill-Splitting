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
    lazy var database = Firestore.firestore()
    
    func addSubscriptionData(subscription: Subscription, completion: @escaping (String) -> Void) {
        let ref = database.collection(FirebaseCollection.subscription.rawValue).document()
        var subscriptionData = subscription
        subscriptionData.doucmentId = "\(ref.documentID)"
        do {
            try database.collection(FirebaseCollection.subscription.rawValue)
                .document("\(ref.documentID)")
                .setData(from: subscriptionData)
            completion("\(ref.documentID)")
        } catch {
            print(error)
        }
    }
    
    func addSubscriptionInvolvedExpense(involvedUserId: String, price: Double, documentId: String) {
        let involvedInfo = SubscriptionMember(
            documentId: documentId, involvedUser: involvedUserId, involvedPrice: price)
        
        do {
            try database.collection(FirebaseCollection.subscription.rawValue)
                .document(documentId)
                .collection(FirebaseCollection.involvedInfo.rawValue)
                .document()
                .setData(from: involvedInfo)
        } catch {
            print(error)
        }
    }
    
    func fetchSubscriptionData(groupId: String, completion: @escaping (Result<[Subscription], Error>) -> Void) {
        database.collection(FirebaseCollection.subscription.rawValue)
            .whereField("groupId", isEqualTo: groupId)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    
                    var subscriptions = [Subscription]()
                    
                    for document in querySnapshot!.documents {
                        
                        do {
                            if let subscription = try document.data(as: Subscription.self, decoder: Firestore.Decoder()) {
                                subscriptions.append(subscription)
                            }
                        } catch {
                            
                            completion(.failure(error))
                        }
                    }
                    completion(.success(subscriptions))
                }
            }
    }
    
    func updateSubscriptionData(documentId: String, newStartTime: Double) {
        let subscriptionTimeRef = database.collection(FirebaseCollection.subscription.rawValue)
            .document(documentId)
        subscriptionTimeRef.updateData(["startTime": newStartTime])
    }
    
    func deleteSubscriptionDocument(documentId: String) {
        database.collection(FirebaseCollection.subscription.rawValue)
            .document(documentId)
            .delete { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
    }
    
    func fetchSubscriptionInvolvedData(
        documentId: String, completion: @escaping (Result<[SubscriptionMember], Error>) -> Void) {
        database.collection(FirebaseCollection.subscription.rawValue)
            .document(documentId)
            .collection(FirebaseCollection.involvedInfo.rawValue)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    
                    var involvedItems: [SubscriptionMember] = []
                    
                    for document in querySnapshot!.documents {
                        
                        do {
                            if let item = try document.data(as: SubscriptionMember.self, decoder: Firestore.Decoder()) {
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
