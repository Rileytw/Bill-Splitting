import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class UserManager {
    static var shared = UserManager()
    lazy var db = Firestore.firestore()
    
    func addUserData(userData: UserData, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try db.collection(FirebaseCollection.user.rawValue).document(userData.userId).setData(from: userData)
            completion(.success("update"))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    func fetchFriendData(userId: String, completion: @escaping (Result<[Friend], Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(userId).collection("friend").getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var friends = [Friend]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let friend = try document.data(as: Friend.self, decoder: Firestore.Decoder()) {
                            friends.append(friend)
                        }
                        
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                completion(.success(friends))
            }
        }
    }
   
    func listenFriendData(userId: String, completion: @escaping () -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(userId).collection("friend").addSnapshotListener() { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error retreiving snapshots \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New: \(diff.document.data())")
                    completion()
                }
            }
        }
    }
    
    //    Use friendId to get user's name in user collection (Using in friendInvitation)
    func fetchUserData(friendId: String, completion: @escaping (Result<UserData?, Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).whereField("userId", isEqualTo: friendId).addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var userData: UserData?
                
                if querySnapshot!.documents.isEmpty == true {
                    completion(.success(nil))
                }
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let user = try document.data(as: UserData.self, decoder: Firestore.Decoder()) {
                            userData = user
                        } else {
                            completion(.success(nil))
                        }
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
               
                completion(.success(userData))
            }
        }
    }
    
    func fetchMembersData(membersId: [String], completion: @escaping (Result<[UserData], Error>) -> Void) {
        var users: [UserData] = []
        var userData: UserData?
        
        for member in membersId {
            
            db.collection(FirebaseCollection.user.rawValue).whereField("userId", isEqualTo: member).getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    
                    completion(.failure(error))
                } else {
                    
                    for document in querySnapshot!.documents {
                        
                        do {
                            if let user = try document.data(as: UserData.self, decoder: Firestore.Decoder()) {
                                userData = user
                                if let userData = userData {
                                    users.append(userData)
                                    completion(.success(users))
                                }
                            }
                        } catch {
                            
                            completion(.failure(error))
                            return
                        }
                    }
                }
            }
          
        }
        
    }
    
    
    func fetchUsersData(completion: @escaping (Result<[UserData], Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var userData: [UserData] = []
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let user = try document.data(as: UserData.self, decoder: Firestore.Decoder()) {
                            userData.append(user)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(userData))
            }
        }
    }
    
    func addPaymentData(paymentName: String?, account: String?, link: String?) {
        let ref = db.collection(FirebaseCollection.user.rawValue).document(AccountManager.shared.currentUser.currentUserId)
        let replyDictionary = ["paymentName": paymentName, "paymentAccount": account, "paymentLink": link ]
        
        ref.updateData(["payment": FieldValue.arrayUnion([replyDictionary])]) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteUserPayment(userId: String, paymentName: String?, account: String?, link: String?, completion: @escaping (Result<(), Error>) -> Void) {
        
        let replyDictionary = ["paymentName": paymentName, "paymentAccount": account, "paymentLink": link ]
        
        db.collection(FirebaseCollection.user.rawValue).document(userId).updateData([
            "payment": FieldValue.arrayRemove([replyDictionary])
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Document successfully updated")
                completion(.success(()))
            }
        }
    }
    

//   MARK: - Change getDocuments to addSnapshotListener
    func fetchSignInUserData(userId: String, completion: @escaping (Result<UserData?, Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).whereField("userId", isEqualTo: userId).addSnapshotListener { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                do {
                    if let user = try querySnapshot!.documents.first?.data(as: UserData.self, decoder: Firestore.Decoder()) {
                        completion(.success(user))
                    } else {
                        completion(.success(nil))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteUserData(userId: String, userName: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(userId).updateData([
            "userEmail": "",
            "payment": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Document successfully updated")
                completion(.success(()))
            }
        }
    }
    
    func deleteFriendCollection(documentId: String, collection: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(documentId).collection(collection).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
                return
            }
            
            for document in querySnapshot!.documents {
                print("Deleting \(document.documentID) => \(document.data())")
                document.reference.delete()
                completion(.success(()))
            }

            if querySnapshot!.documents.isEmpty == true {
                completion(.success(()))
            }
        }
    }
    
    func deleteDropUserData(friendId: String, collection: String, userId: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(friendId).collection("friend").document(userId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully removed!")
                completion(.success(()))
            }
        }
    }
    
    func updateUserName(userId: String, userName: String, completion: @escaping (Result<(), Error>) -> Void) {
        db.collection(FirebaseCollection.user.rawValue).document(userId).updateData([
            "userName": userName
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
                completion(.failure(error))
            } else {
                print("Document successfully updated")
                completion(.success(()))
            }
        }
    }
        
    static func renameBlockedUser(blockList: [String], userData: [UserData]) -> [UserData] {
        var blockedUserData = userData
        for user in blockList {
            for index in 0..<userData.count {
                if userData[index].userId.contains(user) {
                    blockedUserData[index].userName = blockedUserData[index].userName + "(已封鎖)"
                }
            }
        }
       return blockedUserData
    }
    
    
}
