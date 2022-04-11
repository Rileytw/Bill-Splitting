import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class UserManager {
    static var shared = UserManager()
    let db = Firestore.firestore()
    
    func fetchFriendData(userId: String, completion: @escaping (_ data: [Friend]) -> Void) {
        db.collection("User").document(userId).collection("friend").getDocuments() { snapshot, error in
            
            guard let snapshot = snapshot else { return }
            
            let friendData = snapshot.documents.compactMap { snapshot in
                try? snapshot.data(as: Friend.self)
            }
            completion(friendData)
        }
    }
}
