//
//  SignUpManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/26.
//

import UIKit
import Firebase
import FirebaseAuth

class AccountManager {
    static var shared = AccountManager()
    var currentUser = CurrentUser(currentUserId: "", currentUserEmail: "")
    
    func signUpWithFireBase(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user,
                  error == nil else {
                      print(error?.localizedDescription)
                      return
                  }
            completion("\(user.uid)")
        }
    }
    
    func signInWithFirebase(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            guard let uid = result?.user.uid else { return }
            completion("\(uid)")
        }
    }
    
    func deleteAccount(completion: @escaping (Result<(), Error>) -> Void) {
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
              } else {
                  completion(.success(()))
              }
        })
    }
    
    
    func getCurrentUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else { return }
        let uid = user.uid
        let email = user.email
        self.currentUser.currentUserId = uid
        self.currentUser.currentUserEmail = email ?? ""
    }
}
