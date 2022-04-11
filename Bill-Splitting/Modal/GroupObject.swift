//
//  GroupObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GroupData: Codable {
    var groupId: String
    var groupName: String
    var goupDescription: String?
    var creator: String
    var type: Int
    var status: Int
    var member: [Member]
}

struct Member: Codable {
    var userId: String
}



