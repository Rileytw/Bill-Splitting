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
    var currentUser: CurrentUser {
        let user = CurrentUser(currentUserId: Auth.auth().currentUser?.uid ?? "", currentUserEmail: Auth.auth().currentUser?.email ?? "")
        return user
    }
//    var currentUser = CurrentUser(currentUserId: Auth.auth().currentUser?.uid ?? "", currentUserEmail: Auth.auth().currentUser?.email ?? "")
//    var currentUser = CurrentUser(currentUserId: "", currentUserEmail: "")
    
    func signUpWithFireBase(email: String, password: String, completion: @escaping (Result<(SignUpAuth), Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print("\(error.localizedDescription)")
                completion(.failure(error))
            }
            
            if let user = result?.user {
                let userAuth = SignUpAuth(userId: user.uid, userEmail: user.email ?? "")
                completion(.success(userAuth))
            }
        }
    }
    
    func signInWithFirebase(email: String, password: String, completion: @escaping (Result<(String), Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                print(error.localizedDescription)
            }
            
            if let uid = result?.user.uid {
                completion(.success("\(uid)"))
            }
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
        if let user = currentUser {
            let uid = user.uid
            let email = user.email
//            self.currentUser.currentUserId = uid
//            self.currentUser.currentUserEmail = email ?? ""
        }
    }
    
    func logOutAccount(completion: @escaping (Result<(), Error>) -> Void) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                completion(.success(()))
            } catch let error as NSError {
                completion(.failure(error))
            }
        }
    }
    
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "Email 已被註冊"
        case .userNotFound:
            return "帳號不存在，請重新確認"
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Email 無效，請重新確認"
        case .networkError:
            return "網路連線不穩定，請稍後再試"
        case .weakPassword:
            return "密碼必須超過 6 個字母"
        case .wrongPassword:
            return "密碼錯誤，請重新確認"
        default:
            return "發生錯誤，請稍後再試"
        }
    }
}

struct SignUpAuth {
    var userId: String
    var userEmail: String
}
