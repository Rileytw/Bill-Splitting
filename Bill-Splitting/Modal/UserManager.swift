import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

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
                        completion(.success(friends))

                    } catch {
                        
                        completion(.failure(error))
                        //                            completion(.failure(FirebaseError.documentError))
                    }
                }
//                completion(.success(friends))
            }
        }
    }
}
