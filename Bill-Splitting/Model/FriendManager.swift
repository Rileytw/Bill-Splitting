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
    static var shared = FriendManager()
    lazy var db = Firestore.firestore()
    
    func fetchFriendUserData(userEmail: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        db.collection("user").whereField("userEmail", isEqualTo: userEmail).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var userData: UserData?
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let user = try document.data(as: UserData.self, decoder: Firestore.Decoder()) {
                            userData = user
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                guard let userData = userData else { return }
                
                completion(.success(userData))
            }
        }
    }
    
    func fetchSenderInvitation(userId: String, friendId: String, completion: @escaping (Result<Invitation, Error>) -> Void) {
        
        db.collection("friendInvitation").whereField("senderId", isEqualTo: userId).whereField("receiverId", isEqualTo: friendId).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var invitationData: Invitation?
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let invitation = try document.data(as: Invitation.self, decoder: Firestore.Decoder()) {
                            invitationData = invitation
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                guard let invitationData = invitationData else { return }
                
                completion(.success(invitationData))
            }
        }
    }
    
    func fetchReceiverInvitation(userId: String, friendId: String, completion: @escaping (Result<Invitation, Error>) -> Void) {
        
        db.collection("friendInvitation").whereField("senderId", isEqualTo: friendId).whereField("receiverId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var invitationData: Invitation?
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let invitation = try document.data(as: Invitation.self, decoder: Firestore.Decoder()) {
                            invitationData = invitation
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                guard let invitationData = invitationData else { return }
                
                completion(.success(invitationData))
            }
        }
    }
    
    func updateFriendInvitation(senderId: String, receiverId: String) {
        let ref = db.collection("friendInvitation").document()
        ref.setData(["senderId": senderId,
                     "receiverId": receiverId,
                     "documentId": "\(ref.documentID)"])
    }
    
    func fetchFriendInvitation(userId: String, completion: @escaping (Result<[Invitation], Error>) -> Void) {
        
        db.collection("friendInvitation").whereField("receiverId", isEqualTo: userId).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var invitationData: [Invitation] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let invitation = try document.data(as: Invitation.self, decoder: Firestore.Decoder()) {
                            invitationData.append(invitation)
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(invitationData))
            }
        }
    }
    
    func deleteFriendInvitation(documentId: String) {
        db.collection("friendInvitation").document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func senderToFriends(userId: String, senderId: String, senderName: String, senderEmail: String) {
        let senderData = Friend(userId: senderId, userName: senderName, userEmail: senderEmail)
        
        do {
            try db.collection("user").document(userId).collection("friend").document(senderId).setData(from: senderData)
        } catch {
            print(error)
        }
    }
    
    func receiverToFriends(userId: String, senderId: String, userName: String, userEmail: String) {
        let receiverData = Friend(userId: userId, userName: userName, userEmail: userEmail)
        do {
            try db.collection("user").document(senderId).collection("friend").document(userId).setData(from: receiverData)
        } catch {
            print(error)
        }
    }
    
    func removeFriend(userId: String, friendId: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(userId).collection("friend").document(friendId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully removed!")
                completion(.success(()))
            }
        }
    }
    
    func addBlockFriends(userId: String, blockedUser: String, completion: @escaping (Result<(), Error>) -> Void) {
        let blackListRef = db.collection(FirebaseCollection.user.rawValue).document(userId)
        blackListRef.updateData([
            "blackList": FieldValue.arrayUnion([blockedUser])
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
}
