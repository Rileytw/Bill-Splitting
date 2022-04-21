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
        
//        let reminder = Reminder(groupId: groupId, memberId: memberId, type: type, remindTime: remindTime)
        
        do {
            try db.collection(FireBaseCollection.reminder.rawValue).document("\(ref.documentID)").setData(from: reminder)
//            completion(remindTime)
        } catch {
            print(error)
        }
    }
}
