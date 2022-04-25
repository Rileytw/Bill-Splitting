import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

// MARK: Fake data for testing
let userId = "07MPW5R5bYtYQWuDdUXb"
let userEmail = "riley@gmail.com"
let userName = "Riley"

class UserManager {
    static var shared = UserManager()
    lazy var db = Firestore.firestore()
    
    func addUserData(userData: UserData, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = db.collection(FireBaseCollection.user.rawValue).document()
        
        var userData = userData
        userData.userId = "\(ref.documentID)"
        do {
            try db.collection(FireBaseCollection.user.rawValue).document("\(ref.documentID)").setData(from: userData)
            completion(.success("\(ref.documentID)"))
        } catch {
            print(error)
            completion(.failure(error))
        }
    }
    
    func fetchFriendData(userId: String, completion: @escaping (Result<[Friend], Error>) -> Void) {
        db.collection(FireBaseCollection.user.rawValue).document(userId).collection("friend").getDocuments() { (querySnapshot, error) in
            
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
    
    //    Use friendId to get user's name in user collection (Using in friendInvitation)
    func fetchUserData(friendId: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        db.collection(FireBaseCollection.user.rawValue).whereField("userId", isEqualTo: friendId).addSnapshotListener { (querySnapshot, error) in
            
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
    
    func fetchUsersData(completion: @escaping (Result<[UserData], Error>) -> Void) {
        db.collection(FireBaseCollection.user.rawValue).getDocuments() { (querySnapshot, error) in
            
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
        let ref = db.collection(FireBaseCollection.user.rawValue).document(userId)
        let replyDictionary = ["paymentName": paymentName, "paymentAccount": account, "paymentLink": link ]
        
        ref.updateData(["payment": FieldValue.arrayUnion([replyDictionary])]) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
