//
//  GroupManager.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

enum Grouptype: Int {
    case personal = 0
    case group = 1
}

class GroupManager {
    static var shared = GroupManager()
    let db = Firestore.firestore()
    
    func addGroupData(name: String, description: String?, creator: String, type: Int, status: Int, member: [Member]) {
        let ref = db.collection("group").document()
        
        let groupData = GroupData(groupId: "\(ref.documentID)", groupName: name, goupDescription: description, creator: creator, type: type, status: status, member: member)
        
        do {
            try db.collection("group").document().setData(from: groupData)
        } catch {
            print(error)
        }
    }
}
