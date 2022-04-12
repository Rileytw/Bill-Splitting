//
//  UserObject.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/4/11.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore

struct UserData: Codable {
    var userId: String
    var userName: String
    var userEmail: String
    var group: [String]?
}

struct Friend: Codable {
    var userId: String
    var userName: String
    var userEmail: String
}
