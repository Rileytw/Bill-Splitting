//
//  FriendManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/12.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class FriendManager {
    static var shared = UserManager()
    lazy var db = Firestore.firestore()
        
    func updateFriendInvitationDocument(senderId: String, receiverId: String) {
        let ref = db.collection("friendInvitation").document()
        ref.setData(["senderId": senderId,
                     "receiverId": receiverId,
                     "document_id": "\(ref.documentID)"])
    }
    
    func deleteFriendInvitationDocument(documentId: String) {
        db.collection("friendInvitation").document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func senderToFriends(userId: String, senderId: String) {
        let ref = db.collection("user").document(userId).collection("friend").document(senderId)
        
//        ref.updateData([
//            "friends": FieldValue.arrayUnion([myId])
//        ])
    }
    
    func receiverToFriends(userId: String, senderId: String) {
        let ref = db.collection("user").document(senderId).collection("friend").document(userId)
        
//        ref.updateData([
//            "friends": FieldValue.arrayUnion([senderId ?? ""])
//        ])
        
    }
}
