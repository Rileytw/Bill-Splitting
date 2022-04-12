import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

// MARK: Fake data for testing
let userId = "jl9QrNzpBf4uPGtZ3lw6"

class UserManager {
    static var shared = UserManager()
    lazy var db = Firestore.firestore()
    
    func fetchFriendData(userId: String, completion: @escaping (Result<[Friend], Error>) -> Void) {
        db.collection("user").document(userId).collection("friend").getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var friends = [Friend]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let friend = try document.data(as: Friend.self, decoder: Firestore.Decoder()) {
                            friends.append(friend)
                        }
//                        completion(.success(friends))

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
        db.collection("user").whereField("userId", isEqualTo: friendId).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var userData: UserData?
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let user = try document.data(as: UserData.self, decoder: Firestore.Decoder()) {
                            userData = user
                        }
//                        guard let userData = userData else { return }
//
//                        completion(.success(userData))
//
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                guard let userData = userData else { return }
                
                completion(.success(userData))
                
            }
        }
    }
}
