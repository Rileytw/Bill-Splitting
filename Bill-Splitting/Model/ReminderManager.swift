//
//  ReminderManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/21.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

class ReminderManager {
    static var shared = ReminderManager()
    lazy var db = Firestore.firestore()
    
    func addReminderData(reminder: Reminder) {
        let ref = db.collection(FireBaseCollection.reminder.rawValue).document()
        
        do {
            try db.collection(FireBaseCollection.reminder.rawValue).document("\(ref.documentID)").setData(from: reminder)
        } catch {
            print(error)
        }
    }
    
    func fetchReminders(completion: @escaping (Result<[Reminder], Error>) -> Void) {
        db.collection(FireBaseCollection.reminder.rawValue).whereField("creatorId", isEqualTo: userId).order(by: "remindTime", descending: true).getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                
                var reminders = [Reminder]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let reminder = try document.data(as: Reminder.self, decoder: Firestore.Decoder()) {
                            reminders.append(reminder)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(reminders))
            }
        }
    }
}
