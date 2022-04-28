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
    
    func deleteAccount() {
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { error in
            if let error = error {
                print(error.localizedDescription)
                print(error)
                
              } else {
                print("Account successfully deleted ")
              }
        })
    }
}
